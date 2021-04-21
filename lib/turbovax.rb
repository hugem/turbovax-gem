# frozen_string_literal: true

require "logger"

require_relative "turbovax/version"
require_relative "turbovax/portal"
require_relative "turbovax/location"
require_relative "turbovax/appointment"
require_relative "turbovax/easy_test_portal"
require_relative "turbovax/data_fetcher"

require_relative "turbovax/twitter/client"
require_relative "turbovax/twitter/individual_location_handler"

module Turbovax
  # TODO: (configure logger)
  def self.logger
    @logger ||= Logger.new($stdout)
    @logger.level = Logger::INFO
    @logger
  end
end
