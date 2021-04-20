# frozen_string_literal: true

require_relative "turbovax/version"
require_relative "turbovax/portal"
require_relative "turbovax/location"
require_relative "turbovax/appointment"
require_relative "turbovax/easy_test_portal"
require_relative "turbovax/data_fetcher"

require_relative "turbovax/twitter/client"
require_relative "turbovax/twitter/individual_location_handler"

module Turbovax
  class Error < StandardError; end
  # Your code goes here...

  def self.test; end
end

