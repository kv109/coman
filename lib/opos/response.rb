class Opos::Response
  require_relative 'response/code_value'
  require_relative 'response/code_and_status_validator'
  require_relative 'response/messages_validator'
  require_relative 'response/status_value'

  attr_reader :messages, :value

  def initialize(code: nil, messages: [], status:, value: nil)
    @code     = code
    @messages = messages
    @status   = status
    @value    = value

    validate
  end

  def code
    code_value.get
  end

  def error(&block)
    block.call(value, messages) if block_given? && status_value.error?
    self
  end

  def ok(&block)
    block.call(value, messages) if block_given? && status_value.ok?
    self
  end

  def status
    status_value.get
  end

  def to_s
    [].tap do |string|
      string << "status=#{status}"
      string << "messages=#{messages.join(', ')}" if messages.present?
      string << "value=#{value}" if value
    end.join(', ').insert(0, 'RESULT: ')
  end

  private

  def code_value
    return @code_value if @code_value
    if @code.nil?
      @code = 200 if status_value.ok?
      @code = 400 if status_value.error?
    end
    @code_value = Opos::Response::CodeValue.new(code: @code, status_value: status_value)
  end


  def status_value
    @status_value ||= Opos::Response::StatusValue.new(status: @status)
  end

  def validate
    # Values are validated on initialize
    status_value
    code_value
    [
      Opos::Response::CodeAndStatusValidator.new(code_value: code_value, status_value: status_value),
      Opos::Response::MessagesValidator.new(messages: messages)
    ].each(&:validate)
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
