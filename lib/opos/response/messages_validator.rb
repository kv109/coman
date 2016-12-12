class Opos::Response::MessagesValidator
  require_relative 'response_errors'

  def initialize(messages:)
    @messages = messages
  end

  def validate
    messages.each(&method(:validate_message))
  end

  private

  def validate_message(message)
    error = Opos::Response::InvalidMessageError.new(message: message)
    raise error unless message.is_a?(String)
    raise error if message.size < 1
  end

  private

  attr_reader :messages
end
