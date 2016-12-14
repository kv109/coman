class Opos::Response::StatusValue
  require_relative 'status_validator'

  ALLOWED_STATUSES = [:error, :ok]; private_constant :ALLOWED_STATUSES

  def initialize(status:)
    @status = status

    validate
  end

  def get
    status.to_sym
  end

  def validate
    Opos::Response::StatusValidator.new(allowed_statuses: ALLOWED_STATUSES, status: status).validate
  end

  private

  attr_reader :status
end
