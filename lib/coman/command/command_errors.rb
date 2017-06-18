class Coman::Command::Error < StandardError
end

class Coman::Command::CannotOverrideMethod < Coman::Command::Error
  def initialize(extended_class:, reserved_method_name:)
    super("#{extended_class} already implements ##{reserved_method_name}.")
  end
end
