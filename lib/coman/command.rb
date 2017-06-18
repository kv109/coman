module Coman
  module Command
    require_relative 'command/command_errors'

    RESPONSE_METHOD_NAME = :response.freeze; private_constant :RESPONSE_METHOD_NAME

    def self.included(base)
      if base.instance_methods.include?(RESPONSE_METHOD_NAME)
        raise CannotOverrideMethod.new(extended_class:       base,
                                       reserved_method_name: RESPONSE_METHOD_NAME)
      end

      define_method RESPONSE_METHOD_NAME do

      end
    end
  end
end
