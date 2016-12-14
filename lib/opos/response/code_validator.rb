class Opos::Response::CodeValidator
  require_relative 'response_errors'

  def initialize(codes_map:, code:, status_value:)
    @codes_map = codes_map
    @code = code
    @status_value = status_value
  end

  def validate
    unless allowed_codes.include?(code)
      raise Opos::Response::InvalidCodeError.new(allowed_codes: allowed_codes, code: code)
    end

    if status_and_code_mismatch?
      raise Opos::Response::StatusAndCodeMismatchError.new(code: code, status: status_value.get)
    end
  end

  private

  def allowed_codes
    codes_map.keys + codes_map.values
  end

  def error_codes
    filtered_map = codes_map.select { |key, value| key >= 400 && key < 500 }
    filtered_map.keys + filtered_map.values
  end

  def status_and_code_mismatch?
    (status_value.ok? && !success_codes.include?(code)) || (status_value.error? && !error_codes.include?(code))
  end

  def success_codes
    filtered_map = codes_map.select { |key, value| key < 400 }
    filtered_map.keys + filtered_map.values
  end

  attr_reader :codes_map, :code, :status_value
end
