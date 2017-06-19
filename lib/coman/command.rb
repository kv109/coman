module Coman
  module Command
    require_relative 'command/command_errors'

    CALL_METHOD_NAME = :call.freeze; private_constant :CALL_METHOD_NAME
    RESPONSE_METHOD_NAME = :response.freeze; private_constant :RESPONSE_METHOD_NAME

    def self.included(base)
      instance_methods = base.instance_methods

      if instance_methods.include?(RESPONSE_METHOD_NAME)
        raise CannotOverrideMethod.new(extended_class:       base,
                                       reserved_method_name: RESPONSE_METHOD_NAME)
      end

      unless instance_methods.include?(CALL_METHOD_NAME)
        raise NotImplementedError, "#{Coman::Command} expects #{base} to implement ##{CALL_METHOD_NAME}"
      end

      define_method RESPONSE_METHOD_NAME do
      end
    end

    def self.extended(instance)
      included(instance.class)
    end
  end
end
