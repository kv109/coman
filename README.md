# Coman

Simple DSL for [Service Objects](http://multithreaded.stitchfix.com/blog/2015/06/02/anatomy-of-service-objects-in-rails/).

As for now `Coman` provides one simple class: `Coman::Response`.

`Coman::Response` object represents a result of calling a service. It has:
- status - OK or ERROR
- code - one of 2xx, 4xx or 5xx HTTP codes
- result - e.g. `ActiveRecord` object
- messages - array of strings which describes a command execution result (usually error messages).

Simple and restricted API of `Coman::Response` allows to handle responses in a unambiguous, expected way.

## Usage

```ruby
class CreateUserService < Struct.new(:user)
  def execute
    if user.save
      Coman::Response.ok(result: user)
    else
      Coman::Response.error(messages: user.errors.full_messages)
    end
  end
end

class UsersController
  def create
    command = CreateUserService.new(User.new)

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

## Philosophy 
We communicate with countless external services every day. We know how to talk to them and we know what their responses mean. 
`Coman` encourages thinking about internal services in our applications as external services: separate, independent parts which share communication interface.

Services usually implement a public method like `process`, `call` or `perform` and that's how API for **calling** services is unified. 
However providing a separate interface for what these methods return - for **results** - is less common. For now `Coman` supports that by providing simple `Coman::Response` class which represents a result of a service work.

In other words, if we know how to "send a request" to a service, we should also know how to handle its "response".
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

