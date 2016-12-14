class Opos::Response::CodeAndStatusValidator
  require_relative 'response_errors'

  def initialize(code_value:, status_value:)
    @code_value = code_value
    @status_value = status_value
  end

  def validate
    if code_and_status_mismatch?
      raise Opos::Response::StatusAndCodeMismatchError.new(code: code_value.get, status: status_value.get)
    end
  end

  private

  def code_and_status_mismatch?
    (code_value.error? && !status_value.error?) || (code_value.ok? && !status_value.ok?)
  end

  attr_reader :code_value, :status_value
end
