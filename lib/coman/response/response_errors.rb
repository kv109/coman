class Coman::Response::Error < StandardError
  def inclusion_text(array)
    "has to be in [#{array.join(', ')}]"
  end
end

class Coman::Response::InvalidCodeError < Coman::Response::Error
  def initialize(allowed_codes:, code:)
    super("Invalid code (code=#{code}), #{inclusion_text(allowed_codes)}")
  end
end

class Coman::Response::StatusAndCodeMismatchError < Coman::Response::Error
  def initialize(code:, status:)
    super("Status (status=#{status}) and code (code=#{code}) don't match")
  end
end

class Coman::Response::InvalidMessageError < Coman::Response::Error
  def initialize(message:)
    if message == ''
      message = '[empty string]'
    else
      message = "#{message}:#{message.class}"
    end
    super("Invalid message (message=#{message}), has to be non-empty String")
  end
end

class Coman::Response::InvalidStatusError < Coman::Response::Error
  def initialize(allowed_statuses:, status:)
    super("Invalid status (status=#{status}), #{inclusion_text(allowed_statuses)}")
  end
end
