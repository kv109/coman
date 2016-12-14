class Coman::Response::CodeValue
  require_relative 'code_validator'

  CODES_MAP = {
    200 => :ok,
    201 => :created,
    202 => :accepted,
    203 => :non_authoritative_information,
    204 => :no_content,
    205 => :reset_content,
    206 => :partial_content,
    207 => :multi_status,
    208 => :already_reported,
    226 => :im_used,
    400 => :bad_request,
    401 => :unauthorized,
    402 => :payment_required,
    403 => :forbidden,
    404 => :not_found,
    405 => :method_not_allowed,
    406 => :not_acceptable,
    407 => :proxy_authentication_required,
    408 => :request_time_out,
    409 => :conflict,
    410 => :gone,
    411 => :length_required,
    412 => :precondition_failed,
    413 => :payload_too_large,
    414 => :uri_too_long,
    415 => :unsupported_media_type,
    416 => :range_not_satisfiable,
    417 => :expectation_failed,
    418 => :i_m_a_teapot,
    421 => :misdirected_request,
    422 => :unprocessable_entity,
    423 => :locked,
    424 => :failed_dependency,
    426 => :upgrade_required,
    428 => :precondition_required,
    429 => :too_many_requests,
    431 => :request_header_fields_too_large,
    451 => :unavailable_for_legal_reasons
  }; private_constant :CODES_MAP

  def initialize(code:)
    @code = code

    validate
  end

  def ==(other)
    get == other.get
  end

  def get
    return @get if @get
    @get = code if code.is_a?(Fixnum)
    @get = CODES_MAP.key(code) if code.is_a?(Symbol)
    @get
  end

  def error?
    get >= 400 && get < 600
  end

  def ok?
    get >= 200 && get < 300
  end

  def validate
    Coman::Response::CodeValidator.new(allowed_codes: self.class.allowed_codes, code: code).validate
  end

  private

  attr_reader :code

  class << self
    def allowed_codes
      CODES_MAP.keys + CODES_MAP.values
    end
  end
end
