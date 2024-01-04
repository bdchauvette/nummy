# Nummy

> Tasty enumeration utilities for Ruby

Nummy provides utilities that that build on Ruby's Enumerable module to
provide functionality like enumerated types ("enums"), enumerating over
constants in a module, and iterating over the members of data classes.

> [!NOTE]
> This module does NOT add additional methods to the Enumerable module, or change its behavior in any way.

## Installation

Install the gem and add to the application's Gemfile by executing:

```console
bundle add nummy
```

If bundler is not being used to manage dependencies, install the gem by executing:

```console
gem install nummy
```

## Usage

To load `nummy`, use:

```ruby
require "nummy"
```

This will lazily require (using `autoload`) the individual utilities as needed.

You can also explicitly load individual modules:

```ruby
require "nummy/enum"
require "nummy/member_enumerable"
# ...
```

### `Nummy::Enum`

The main feature of Nummy is the `Nummy::Enum` class, which is an opinionated class that can be used to define [enumerated types](https://en.wikipedia.org/wiki/Enumerated_type) ("enums") that use Ruby constants for the key-value pairs.

The recommended way to use `Nummy::Enum` is to define constants explicitly:

#### Creating (Recommended)

```ruby
require "nummy"

class CardinalDirection < Nummy::Enum
  NORTH = 0
  EAST = 90
  SOUTH = 180
  WEST = 270
end
```

> [!TIP]
> Statically defining the constants like this allows the enums to work really nicely out of the box with language servers like [Ruby LSP](https://github.com/Shopify/ruby-lsp) because the fields are just statically defined constants. The sugary ways of defining enums (see below) use `const_set` behind the scenes, which does not work as well with language servers and tooling.

If you don't particularly care about the values, you can use the `auto` helper to define them automatically:

```ruby
class Status < Nummy::Enum
  DRAFT = auto
  PUBLISHED = auto
  ARCHIVED = auto
end
```

> [!TIP]
> `auto` comes from the `Nummy::AutoSequenceable` module, and has some extra features not shown in this example. For more information, see the section below on `Nummy::AutoSequenceable`.

#### Creating (Sugar)

There are also two sugary ways to define enums:

```ruby
require "nummy"

Nummy.enum(NORTH: 0, EAST: 90, SOUTH: 180, WEST: 270)

# which is an alias for:
Nummy::Enum.define(NORTH: 0, EAST: 90, SOUTH: 180, WEST: 270)
```

Or if you want the values to be automatically generated:

```ruby
require "nummy"
Status = Nummy.enum(:DRAFT, :PUBLISHED, :ARCHIVED)

Status.pairs
# => [[:DRAFT, 0], [:PUBLISHED, 1], [:ARCHIVED, 2]]
```

You can customize the generated enum by providing a block:

```ruby
require "nummy"

Status = Nummy.enum(:DRAFT, :PUBLISHED, :ARCHIVED) do |enum|
  def self.custom_method
    puts "Hello from #{self}!"
  end
end

Status.custom_method
# => Hello from Status!
```

#### Working with enums

The `Nummy::Enum` class provides a number of methods for working with enums. For example, using the `CardinalDirection` example from above:

```ruby
CardinalDirection.keys
# => [:NORTH, :EAST, :SOUTH, :WEST]

CardinalDirection.values
# => [0, 90, 180, 270]

CardinalDirection.pairs
# => [[:NORTH, 0], [:EAST, 90], [:SOUTH, 180], [:WEST, 270]]

CardinalDirection.include?(90)
# => true
```

They can even be used in `case` expressions to see if the case value is `==` to any of the values in the enum:

```ruby
case some_angle
when CardinalDirection
  puts "The angle is a cardinal direction!"
else
  puts "Not a cardinal direction!"
end
```

> [!TIP]
> `Nummy::Enum` extends `Enumerable` and iterates over the _values_ of the enum, so you have access to things like `.include?(value)`, `.any?`, and `.find`.

#### Rails / ActiveRecord integration

> [!IMPORTANT]
> This integration requires `ActiveSupport::Inflector` to be defined.

To use nummy enums as ActiveRecord enums, you can use the `.to_attribute` method:

```ruby
class Conversation < ActiveRecord::Base
  class Status < Nummy::Enum
    ACTIVE = auto
    ARCHIVED = auto
  end

  enum :status, Status.to_attribute
end
```

This allows you to use all of the Rails magic for enums, like scopes and boolean helpers, while also being able to refer to values in a safer way than hash lookups.

That is, these two are the same:

```ruby
Conversation.statuses[:active] # => 0
Conversation::Status::ACTIVE   # => 0
```

But these are not:

```ruby
Conversation.statuses[:acitve]
# => nil

Conversation::Status::ACITVE   # => nil
# =>
#  uninitialized constant Conversation::Status::ACITVE (NameError)
#  Did you mean?  Conversation::Status::ACTIVE
```

You can get similar behavior using `#fetch`:

```ruby
Conversation.statuses.fetch(:acitve)
# => key not found: :acitve (KeyError)
#    Did you mean?  :active
```

But that still misses out on some of the DX benefits of using constants, like improved support for things like autocompletion, documentation, and navigation ("Go To Definition") in editors.

### `Nummy::MemberEnumerable`

`Nummy::MemberEnumerable` is a module that includes `Enumerable` and makes it possible to iterate over any class or module that responds to `members`.

The motivation for this module is being able to iterate over `Data` classes that represent a finite collection of similar values.

```ruby
require "nummy"

SomeCollection = Data.define(:foo, :bar, :baz) do
  include Nummy::MemberEnumerable
end

collection = SomeCollection[123, 456, 789]

collection.values
# => [123, 456, 789]
```

> [!NOTE]
> The `Nummy::MemberEnumerable` module provides fewer enumeration features than you might expect, because it's modeled after `Struct` rather than `Hash`.

### `Nummy::ConstEnumerable`

`Nummy::ConstEnumerable` is a module that only provides methods to iterate over the names, values, and pairs of a module's own constants. It is meant to provide low-level functionality for other classes, such as `Nummy::Enum`.

```ruby
require "nummy"

module SomeModule
  extend Nummy::ConstEnumerable

  FOO = 123
  BAR = 456
  BAZ = 789
end

SomeModule.each_const_name { |name| puts name }
# => :BAR
# => :BAZ
# => :FOO

SomeModule.each_const_pair.to_a
# => [[:BAR, 456], [:BAZ, 789], [:FOO, 123]]
```

> [!WARNING]
> The enumeration order for `Nummy::ConstEnumerable` is _not_ guaranteed because it uses `Module#constants` behind the scenes.
> If you require stable ordering, see `Nummy::OrderedConstEnumerable`.

### `Nummy::OrderedConstEnumerable`

`Nummy::OrderedConstEnumerable` provides the same API as `Nummy::ConstEnumerable`, but guarantees three things:

- any constants defined _before_ the module is extended will be sorted _alphabetically_ before any other constants
- any constants defined _after_ the module is extended will be sorted in insertion order
- the order of constants is stable across calls

For example:

```ruby
require "nummy"

class CustomEnum
  BEFORE_C = :c
  BEFORE_B = :b
  BEFORE_A = :a

  extend Nummy::OrderedConstEnumerable

  AFTER_Z = :z
  AFTER_Y = :y
  AFTER_X = :x
end

CustomEnum.each_const_name.to_a
# => [:BEFORE_A, :BEFORE_B, :BEFORE_C, :AFTER_Z, :AFTER_Y, :AFTER_X]
```

### `Nummy::AutoSequenceable`

`Nummy::AutoSequenceable` is a module that provides a single method, `auto`, which returns a unique value for each call. It is meant to provide low-level functionality for other classes, such as `Nummy::Enum`.

```ruby
require "nummy"

class Weekday
  extend Nummy::AutoSequenceable
  
  SUNDAY = auto
  MONDAY = auto
  TUESDAY = auto
  WEDNESDAY = auto
  THURSDAY = auto
  FRIDAY = auto
  SATURDAY = auto
end

Weekday::SUNDAY
# => 0

Weekday::SATURDAY
# => 6
```

Like with [`iota` in Go][iota-golang], or [`Enum.auto` in Python][enum-auto-python], you can also customize the sequence behavior:

[iota-golang]: https://go.dev/wiki/Iota
[enum-auto-python]: https://docs.python.org/3/library/enum.html#enum.auto

```ruby
require "nummy"
require "bigdecimal"

module MetricPrefix
  extend Nummy::AutoSequenceable

  DECI  = auto(1) { |n| BigDecimal(10) ** -n }
  CENTI = auto
  MILLI = auto
  MICRO = auto(6)
  NANO  = auto(9)
  
  DECA = auto(1) { |n| BigDecimal(10) ** n }
  HECA = auto
  KILO = auto
  MEGA = auto(6)
  GIGA = auto(9)
end

MetricPrefix::DECI  # => 0.1e0
MetricPrefix::CENTI # => 0.1e-1
MetricPrefix::MILLI # => 0.1e-2
MetricPrefix::MICRO # => 0.1e-5
MetricPrefix::NANO  # => 0.1e-8

MetricPrefix::DECA  # => 0.1e2
MetricPrefix::HECA  # => 0.1e3
MetricPrefix::KILO  # => 0.1e4
MetricPrefix::MEGA  # => 0.1e7
MetricPrefix::GIGA  # => 0.1e10
```

See the implementation, tests, and documentation for more details.

## Development

### Setup

After checking out the repo, run `bin/setup` to install dependencies.

To install this gem onto your local machine, run `bundle exec rake install`.

### Console

You can run `bundle exec rake console` for an interactive prompt that will allow you to experiment with the gem.

The console has a pre-configured `Nummy::Enum` that you can use for testing:

```irb
irb(main):001> CardinalDirection
=> #<CardinalDirection NORTH=0 EAST=90 SOUTH=180 WEST=270>
irb(main):002> CardinalDirection.values
=> [0, 90, 180, 270]
```

### Documentation

You can start a documentation server by running `rake docs`. This will start a server at http://localhost:8808 that will pick up changes to the documentation whenever you refresh the page.

> [!NOTE]
> If you make major changes to the gem, sometimes the server can get in a weird state and display incorrect documentation, especially on the sidebar. If this happens, you can try removing the yard cache with `rm -rf .yardoc`, then restart the server and refresh the docs page.

### Testing

To run tests, you can use:

```console
bundle exec rake test
```

#### Running subsets of tests

To run all of the tests in a specific file, you can use the `TEST` argument:

```console
bundle exec rake test TEST="test/nummy/enum_test.rb"
```

To run a specific test by name, you can use the `N` argument and pass it a name or regex pattern:

```console
bundle exec rake test N="/version/"
```

> [!TIP]
> The `N` argument comes from `Minitest::TestTask`. See [the Minitest README](https://github.com/minitest/minitest#label-Rake+Tasks) or [the Minitest documentation](https://docs.seattlerb.org/minitest/Minitest/TestTask.html) for more information.

> [!TIP]
> You can also combine multiple options together:
>
> ```console
> bundle exec rake test N="/positional args/" TEST=test/nummy/enum_test.rb
> ```

#### Coverage

> [!NOTE]
> Coverage is _not_ collected by default, because our configuration reports incorrect metrics when not run against the entire test suite. We could configure coverage to only report against files that were actually required, but because we lazily load some files, it would be easy to miss coverage for an entire file.

To collect coverage, you can set `COVERAGE` to `true` or `1`:

```console
bundle exec rake test COVERAGE=true
```

```console
bundle exec rake test COVERAGE=1
```

### Releasing

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bdchauvette/nummy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/bdchauvette/nummy/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT No Attribution License](https://opensource.org/licenses/MIT-0).

## Code of Conduct

Everyone interacting in the Nummy project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bdchauvette/nummy/blob/main/CODE_OF_CONDUCT.md).
