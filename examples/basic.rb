require_relative '../lib/coman'

class CreateUserCommand < Struct.new(:user)
  def execute
    if user.save
      Coman::Response.ok(value: user)
    else
      Coman::Response.error(messages: user.errors.full_messages)
    end
  end
end

class User
  def save; true end
end

class UsersController
  def create
    command = CreateUserCommand.new(User.new)

    command.execute
      .ok do |user|
        render json: user
      end
      .error do |messages, value|
        render json: messages
      end
  end

  def render(arg); end
end

UsersController.new.create
