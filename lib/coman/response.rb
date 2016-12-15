class Coman::Response
  require_relative 'response/code_value'
  require_relative 'response/code_and_status_validator'
  require_relative 'response/messages_validator'
  require_relative 'response/status_value'

  attr_reader :messages, :result

  def initialize(code: nil, messages: [], status:, result: nil)
    @code     = code
    @messages = messages
    @status   = status
    @result   = result

    validate
  end

  def code
    code_value.get
  end

  def error(code = nil, &block)
    return self if already_called_for?(:error)
    return self unless block_given?
    return self unless status_value.error?
    return self if code && Coman::Response::CodeValue.new(code: code) != code_value
    block.call(result, messages)
    set_already_called_for(:error)
    self
  end

  def ok(code = nil, &block)
    return self if already_called_for?(:ok)
    return self unless block_given?
    return self unless status_value.ok?
    return self if code && Coman::Response::CodeValue.new(code: code) != code_value
    block.call(result, messages)
    set_already_called_for(:ok)
    self
  end

  def status
    status_value.get
  end

  def to_s
    [].tap do |string|
      string << "status=#{status}"
      string << "messages=#{messages.join(', ')}" if messages.present?
      string << "result=#{result}" if result
    end.join(', ').insert(0, 'RESULT: ')
  end

  private

  def already_called_for?(status)
    already_called_for[status] == true
  end

  def already_called_for
    @already_called_for ||= { error: false, ok: false }
  end

  def code_value
    return @code_value if @code_value
    if @code.nil?
      @code = 200 if status_value.ok?
      @code = 400 if status_value.error?
    end
    @code_value = Coman::Response::CodeValue.new(code: @code)
  end

  def set_already_called_for(status)
    already_called_for[status] = true
  end

  def status_value
    @status_value ||= Coman::Response::StatusValue.new(status: @status)
  end

  def validate
    # Values are validated on initialize
    status_value
    code_value
    [
      Coman::Response::CodeAndStatusValidator.new(code_value: code_value, status_value: status_value),
      Coman::Response::MessagesValidator.new(messages: messages)
    ].each(&:validate)
  end

  class << self
    def error(opts = {})
      new(opts.merge(status: :error))
    end

    def ok(opts = {})
      new(opts.merge(status: :ok))
    end
  end
end
