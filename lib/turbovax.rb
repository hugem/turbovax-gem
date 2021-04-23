# frozen_string_literal: true

require "logger"

require_relative "turbovax/constants"
require_relative "turbovax/version"
require_relative "turbovax/portal"
require_relative "turbovax/location"
require_relative "turbovax/appointment"
require_relative "turbovax/data_fetcher"

require_relative "turbovax/twitter_client"
require_relative "turbovax/handlers/location_handler"

# Turbovax gem
module Turbovax
  class InvalidRequestTypeError < StandardError; end

  def self.configure
    yield self
  end

  def self.logger
    @logger ||= Logger.new($stdout, level: Logger::INFO)
  end

  def self.logger=(logger)
    if logger.nil?
      self.logger.level = Logger::FATAL
      return self.logger
    end

    @logger = logger
  end

  def self.twitter_enabled
    # enable twitter by default
    @twitter_enabled = true if @twitter_enabled.nil?
    @twitter_enabled
  end

  def self.twitter_enabled=(twitter_enabled)
    @twitter_enabled = twitter_enabled
  end

  def self.twitter_credentials
    raise NotImplementedError, "no twitter credentials provided" if @twitter_credentials.nil?

    @twitter_credentials
  end

  def self.twitter_credentials=(twitter_credentials)
    @twitter_credentials = twitter_credentials
  end

  def self.faraday_logging_config
    @faraday_logging_config ||= { headers: false, bodies: false, log_level: :info }
  end

  def self.faraday_logging_config=(faraday_logging_config)
    @faraday_logging_config = faraday_logging_config
  end
end
