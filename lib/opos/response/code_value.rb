class Opos::Response::CodeValue
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
  }

  SUCCESS_CODES_MAP = {
    200 => :ok,
    201 => :created,
    202 => :accepted,
    203 => :non_authoritative_information,
    204 => :no_content,
    205 => :reset_content,
    206 => :partial_content,
    207 => :multi_status,
    208 => :already_reported,
    226 => :im_used
  }; private_constant :SUCCESS_CODES_MAP

  ERROR_CODES_MAP = {
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
  }; private_constant :ERROR_CODES_MAP

  ALLOWED_CODES =
    SUCCESS_CODES_MAP.keys +
    ERROR_CODES_MAP.keys +
    SUCCESS_CODES_MAP.values +
    ERROR_CODES_MAP.values

  def initialize(code:)
    @code = code

    validate
  end

  def get
    return code if code.is_a?(Fixnum)
    return CODES_MAP.key(code) if code.is_a?(Symbol)
  end

  def validate
    Opos::Response::CodeValidator.new(allowed_codes: ALLOWED_CODES, code: code).validate
  end

  private

  attr_reader :code
end
