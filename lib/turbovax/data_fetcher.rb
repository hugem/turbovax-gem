require "date"
require "faraday"

module Turbovax
  # This class, given a portal and a twitter handler:
  #  1) executes request for data
  #  2) passes structured appointment data to twitter handler
  #  3) returns appointment data
  class DataFetcher
    DEFAULT_REQUEST_TIMEOUT = 5

    # @param [Turbovax::Portal]
    # @param [TurboVax::Twitter::Handler] twitter_handler a class handles if appointments are found
    # @param [DateTime] date specific date for request
    def initialize(portal, twitter_handler: nil, date: nil)
      @portal = portal
      @date = date || DateTime.now
      @conn = create_request_connection
      @twitter_handler = twitter_handler
    end

    # @return [Array<Turbovax::Location>] List of locations and appointments
    def execute!
      response = make_request
      # locations = @portal.parse_response(response.body)
      locations = @portal.parse_response_with_portal(response.body)
      @twitter_handler&.new(locations)&.execute!

      locations
    end

    private

    def create_request_connection
      Faraday.new(
        url: @portal.api_base_url,
        headers: @portal.request_headers,
        ssl: { verify: false }
      ) do |faraday|
        faraday.response :logger, nil, { headers: false, bodies: false, log_level: :info }
        faraday.adapter Faraday.default_adapter
      end
    end

    def make_request
      request_type = @portal.request_http_method
      path = @portal.api_path

      log_request(" #{request_type} request #{path}")

      if request_type == :get
        @conn.get(path) do |req|
          req.params = @portal.api_query_params
        end
      else
        @conn.post(path) do |req|
          req.params = @portal.api_query_params
          req.body = @portal.request_body(date: @date)
        end
      end
    end

    def log_request(message)
      puts "[#{self.class}] #{message}"
    end
  end
end
