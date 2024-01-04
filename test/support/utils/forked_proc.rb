# frozen_string_literal: true

require "English"

# Helper for executing test code in a forked process.
#
# This can be used to test code that relies on gems like ActiveSupport that
# pollute the global namespace.
class ForkedProc
  # Executes the given block in a forked process and returns the block result.
  #
  # Raises an exception if the block raises an exception.
  def self.call(&)
    new.call(&)
  end

  private_class_method :new

  attr_reader :reader
  attr_reader :writer

  def initialize
    @reader, @writer = IO.pipe
  end

  def call(&)
    pid = fork_call(&)

    writer.close
    result = reader.read
    Process.wait(pid)

    # We're only marshalling our own objects, so this is safe enough.
    # rubocop:disable Security/MarshalLoad
    Marshal.load(result).tap { |r| raise r if r.is_a?(::Exception) }
    # rubocop:enable Security/MarshalLoad
  end

  def fork_call(&)
    Process.fork do
      reader.close

      result =
        begin
          yield
        rescue StandardError
          $ERROR_INFO
        end

      Marshal.dump(result, writer)

      # skip exit hooks so that we don't accidentally end the test suite
      Process.exit!(true)
    end
  end
end
