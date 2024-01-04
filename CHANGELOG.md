## [Unreleased]

## [0.2.0] - 2024-01-04

- Add `Nummy::Enum.to_attribute`, which converts the enum to a hash that can be passed as the values of an `ActiveRecord::Enum`:
  
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
