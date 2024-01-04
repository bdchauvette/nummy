## [Unreleased]

## [0.3.0] - 2024-01-04

- **Adds additional flexibility to `Nummy::Enum.to_attribute` (#2)

  This release teaches a few new tricks to `Nummy::Enum.to_attribute`:

  - it allows passing a block to fully customize how keys are transformed

  - it looks for `String#underscore` rather than calling into  `ActiveSupport::Inflector.underscore` directly, which means that users can bring their own monkey patch if they want to.

  - it falls back to `Symbol#downcase` if `String#underscore` is not available. If the constants are defined using `SCREAMING_SNAKE_CASE`, this will generally have the same result as calling `String#underscore`, but without requiring ActiveSupport.

  ```ruby
  class ShippingStatus < Nummy::Enum
    IN_TRANSIT = auto
    OUT_FOR_DELIVERY = auto
    DELIVERED = auto
  end
  ```

  ```ruby
  # Without ActiveSupport
  
  ShippingStatus.to_attribute
  # v0.2.0 (❌)
  # => nummy/lib/nummy/enum.rb:379:in `block in to_attribute': uninitialized constant ActiveSupport (NameError)
  # 
  #              ::ActiveSupport::Inflector.underscore(key).to_sym
  #              ^^^^^^^^^^^^^^^

  # v0.3.0 (✅)
  # => {:in_transit=>0, :out_for_delivery=>1, :delivered=>2}
  ```

  ```ruby
  # With ActiveSupport
  require "active_support/core_ext/string/inflections"

  ShippingStatus.to_attribute
  # => {:in_transit=>0, :out_for_delivery=>1, :delivered=>2}

  ShippingStatus.to_attribute { |key| key.to_s.underscore.camelize.to_sym }
  # => {:InTransit=>0, :OutForDelivery=>1, :Delivered=>2}
  ```

- **Adds JSON serialization support (#3)**

  This release adds two methods to `Nummy::Enum`: `.as_json` and `.to_json`. These methods allow you to serialize an enum to JSON.

  ```ruby
  class Status < Nummy::Enum
    ACTIVE = auto
    ARCHIVED = auto
  end

  Status.as_json
  # => {"ACTIVE" => 0, "ARCHIVED" => 1}

  Status.to_json
  # => "{\"ACTIVE\":0,\"ARCHIVED\":1}
  ```

## [0.2.0] - 2024-01-04

- Add `Nummy::Enum.to_attribute` (#1), which converts the enum to a hash that can be passed as the values of an `ActiveRecord::Enum`:
  
  ```ruby
  class Conversation < ActiveRecord::Base
    class Status < Nummy::Enum
      ACTIVE = auto
      ARCHIVED = auto
    end

    enum :status, Status.to_attribute
  end
  ```

  > [!IMPORTANT]
  > The conversion requires that `ActiveRecord::Inflector` is defined, but `nummy` does not depend on `ActiveRecord` directly. If you are using `nummy` in a non-Rails environment, you will need to require `ActiveRecord::Inflector` yourself.

## [0.1.0] - 2024-01-04

- Initial release
