class Opos::Response
  require_relative 'response/messages_validator'
  require_relative 'response/status_validator'

  STATUSES = %i(error ok).freeze; private_constant :STATUSES

  attr_reader :messages, :status, :value

  def initialize(messages: [], status:, value: nil)
    @messages = messages
    @status = status
    @value = value

    messages_validator.validate
    status_validator.validate

    normalize_status
  end

  def error(&block)
    block.call(value, messages) if block_given? && error?
    self
  end

  def ok(&block)
    block.call(value, messages) if block_given? && ok?
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

  def messages_validator
    Opos::Response::MessagesValidator.new(messages: messages)
  end

  def normalize_status
    @status = @status.to_sym
  end

  def status_validator
    Opos::Response::StatusValidator.new(allowed_statuses: STATUSES, status: status)
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
