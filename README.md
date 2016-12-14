# Coman

Simple DSL to support Command pattern

## Usage

```ruby
class CreateUserCommand < Struct.new(:user)
  def execute
    if user.save
      Coman::Response.ok(value: user)
    else
      Coman::Response.error(messages: user.errors.full_messages)
    end
  end
end

class UsersController
  def create
    command = CreateUserCommand.new(User.new)

    command.execute
      .ok do |user|
        render json: user
      end
      .error(401) do
        head :unauthorized
      end
      .error(422) do |user, messages|
        render json: { id: user.id, messages: messages }
      end
      .error do |user, messages|  # any other error
        render json: { error: messages.join(', ') }, status: :bad_request
      end
  end
end

```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'coman'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install coman


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

