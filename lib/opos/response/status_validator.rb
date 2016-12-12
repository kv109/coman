class Opos::Response::StatusValidator
  require_relative 'response_errors'

  def initialize(allowed_statuses:, status:)
    @allowed_statuses = allowed_statuses
    @status = status
  end

  def validate
    error = Opos::Response::InvalidStatusError.new(allowed_statuses: allowed_statuses, status: status)
    raise error unless [String, Symbol].include?(status.class)
    raise error unless allowed_statuses.include?(status.to_sym)
  end

  private

  attr_reader :allowed_statuses, :status
end
