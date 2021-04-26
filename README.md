# Turbovax

Turbovax gem helps you quickly stand up bots that can:
1) fetch data from vaccine websites
2) tweet appointment data
3) return structured appointment data

It does not provide any data storage or web server layers. You can build that functionality on top of the gem by yourself.

## Documentation

Detailed docs can be found at [https://rubydoc.info/github/hugem/turbovax-gem](https://rubydoc.info/github/hugem/turbovax-gem).

## Disclaimer

This gem should only be used for the purposes of improving accessibility to vaccines and not for private gain.

This is not affiliated, associated, authorized, endorsed by, or in any way officially connected with Intuit, Inc or any of its subsidiaries or its affiliates. The names TurboTax as well as related names, marks, emblems and images are registered trademarks of their respective owners.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'turbovax'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install turbovax


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Usage

Initialize configuration:

    Turbovax.configure do |config|
      config.twitter_credentials = {
        consumer_key: "CONSUMER_KEY",
        consumer_secret: "CONSUMER_SECRET",
        access_token: "ACCESS_TOKEN",
        access_token_secret: "ACCESS_TOKEN_SECRET"
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

## Advanced

### Configuration
Specify logger:

    Turbovax.configure do |config|
      config.logger = Logger.new($stdout, level: Logger::DEBUG)
    end

Change Faraday (HTTP request library) logging:

    Turbovax.configure do |config|
      config.faraday_logging_config = {
        headers: true,
        bodies: true,
        log_level: :info
      }
    end

Disable tweets:

    Turbovax.configure do |config|
      config.twitter_enabled = false
    end

### DataFetcher

Provide extra parameters:

    Turbovax::DataFetcher.new(
      TestPortal,
      twitter_handler: Turbovax::Handlers::LocationHandler,
      # will be passed to Portal methods
      extra_params: {
        site_id: 123,
        date: "2021-08-08",
      }
    ).execute!


### Portal

Custom HTTP headers ([curl-to-ruby](https://jhawthorn.github.io/curl-to-ruby/) is helpful here):

    class TestPortal < Turbovax::Portal
      request_headers do
        headers = {}
        headers["Connection"] = "keep-alive"
        headers["Pragma"] = "no-cache"
        headers["Cache-Control"] = "no-cache"
        headers["Sec-Ch-Ua"] = "\"Google Chrome\";v=\"89\", \"Chromium\";v=\"89\", \";Not A Brand\";v=\"99\""
        headers
      end
    end

Use extra params provided by data fetcher:

    class TestPortal < Turbovax::Portal
      request_body do
        {
          site_id: data_fetcher_params[:site_id],
        }
      end
    end

Interpolate variables into URL:

    # resulting URL https://www.example-site.info/abc/2021-08-08
    class TestPortal < Turbovax::Portal
      api_url "https://www.example-site.info/%{site_id}/${date}"
      api_url_variables do
        {
          site_id: data_fetcher_params[:site_id],
          date: data_fetcher_params[:date].strftime("%F"),
        }
      end
    end

Use HTTP POST:

    class TestPortal < Turbovax::Portal
      request_http_method Turbovax::Constants::POST_REQUEST_METHOD
    end

## License

This gem is licensed according to [GNU General Public License v3.0](https://github.com/hugem/turbovax-gem/blob/main/LICENSE).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/hugem/turbovax-gem](https://github.com/hugem/turbovax-gem).
