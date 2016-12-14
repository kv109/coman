class Opos::Response::CodeValidator
  require_relative 'response_errors'

  def initialize(allowed_codes:, code:)
    @allowed_codes = allowed_codes
    @code = code
  end

  def validate
    unless allowed_codes.include?(code)
      raise Opos::Response::InvalidCodeError.new(allowed_codes: allowed_codes, code: code)
    end
  end

  private

  attr_reader :allowed_codes, :code
end
