class Opos::Response::Error < StandardError; end

class Opos::Response::InvalidMessageError < Opos::Response::Error
  def initialize(message:)
    if message == ''
      message = '[empty string]'
    else
      message = "#{message}:#{message.class}"
    end
    super("Invalid message (message=#{message}), has to be non-empty String")
  end
end

class Opos::Response::InvalidStatusError < Opos::Response::Error
  def initialize(allowed_statuses:, status:)
    super("Invalid status (status=#{status}), has to be in [#{allowed_statuses.join(', ')}])")
  end
end
