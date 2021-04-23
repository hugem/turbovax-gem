# frozen_string_literal: true

RSpec.describe Turbovax do
  it "has a version number" do
    expect(Turbovax::VERSION).not_to be nil
  end

  it "can configure without error" do
    expect do
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
    end.not_to raise_error
  end
end
