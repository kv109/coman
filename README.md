# Coman

Simple DSL to support Command pattern

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'coman'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install coman

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
      .error do |messages, value|
        render json: messages
      end
  end
end

```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

