class Opos::Response
  require_relative 'response/response_errors'

  STATUSES = %i(error ok).freeze; private_constant :STATUSES

  attr_reader :messages, :status, :value

  def initialize(messages: [], status:, value: nil)
    @messages = messages
    @status = status
    @value = value

    validate_messages
    validate_status
    validate_value

    normalize_status
  end

  def error(&block)
    block.call(value, messages) if error?
    self
  end

  def ok(&block)
    block.call(value) if ok?
    self
  end

  def to_s
    [].tap do |string|
      string << "status=#{status}"
      string << "messages=#{messages.join(', ')}" if messages.present?
      string << "value=#{value}" if value
    end.join(', ').insert(0, 'RESULT: ')
  end

  def error?; status == :error end
  def ok?; status == :ok end

  private

  def normalize_status
    @status = @status.to_sym
  end

  def validate_value
    true
  end

  def validate_status
    error = Opos::Response::InvalidStatusError.new(status, STATUSES)
    raise error unless [String, Symbol].include?(status.class)
    raise error unless STATUSES.include?(status.to_sym)
  end

  def validate_messages
    messages.each(&method(:validate_message))
  end

  def validate_message(message)
    error = Opos::Response::InvalidMessageError.new(message)
    raise error unless message.is_a?(String)
    raise error if message.size < 1
  end

  class << self
    def ok(opts = nil)
      opts ||= {}
      filtered_opts = {}
      filtered_opts[:messages] = opts[:messages] if opts.has_key?(:messages)
      filtered_opts[:value]    = opts[:value] if opts.has_key?(:value)
      new(filtered_opts.merge(status: :ok))
    end
  end
end
