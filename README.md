# Turbovax

Turbovax gem helps you quickly stand up bots that can:
1) fetch data from vaccine websites
2) tweet appointment data
3) return structured appointment data

It does not provide any data storage or web server layers. You can build that functionality on top of the gem by yourself.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'turbovax'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install turbovax

## Usage

Initialize configuration (optional):

    Turbovax.configure do |config|
      config.logger = Logger.new($stdout, level: Logger::DEBUG)
      config.twitter_enabled = true
      config.twitter_credentials = {
        consumer_key: "CONSUMER_KEY",
        consumer_secret: "CONSUMER_SECRET",
        access_token: "ACCESS_TOKEN",
        access_token_secret: "ACCESS_TOKEN_SECRET"
      }

      config.faraday_logging_config = {
        headers: true,
        bodies: true,
        log_level: :info
      }
    end

Create test portal:

    class TestPortal < Turbovax::Portal
      name "Gotham City Clinic"
      key "gotham_city"
      public_url "https://www.turbovax.info/"
      api_url "http://api.turbovax.info/v1/test.json"
      request_http_method Turbovax::Constants::GET_REQUEST_METHOD

      parse_response do |response|
        response_json = JSON.parse(response)
        Array(response_json["appointments"]).map do |location_json|
          appointments = Array(location_json["slots"]).map do |appointment_string|
            {
              time: DateTime.parse(appointment_string)
            }
          end

          Turbovax::Location.new(
            id: "ID",
            name: location_json["clinic_name"],
            full_address: location_json["area"],
            time_zone: "America/New_York",
            data: {
              vaccine_types: [location_json["vaccine"]],
              appointments: appointments,
            }
          )
        end
      end
    end

Execute operation:

    locations = Turbovax::DataFetcher.new(TestPortal, twitter_handler: Turbovax::Handlers::LocationHandler).execute!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hugem/turbovax-gem.
