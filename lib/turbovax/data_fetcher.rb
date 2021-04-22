# frozen_string_literal: true

require "date"
require "faraday"

module Turbovax
  # This class, given a portal and a twitter handler:
  #  1) executes request for data
  #  2) passes structured appointment data to twitter handler
  #  3) returns appointment data
  class DataFetcher
    # @param [Turbovax::Portal] portal
    # @param [TurboVax::Twitter::Handler] twitter_handler a class handles if appointments are found
    # @param [Hash] extra_params other info that you want to supply to the portal when executing blocks
    def initialize(portal, twitter_handler: nil, extra_params: {})
      @portal = portal
      @extra_params = { date: DateTime.now }.merge(extra_params)
      @conn = create_request_connection
      @twitter_handler = twitter_handler
    end

    # @return [Array<Turbovax::Location>] List of locations and appointments
    def execute!
      response = make_request
      log("make request [DONE]")

      locations = @portal.parse_response_with_portal(response.body, @extra_params)
      log("parse response [DONE]")

      if Turbovax.twitter_enabled
        @twitter_handler&.new(locations)&.execute!
        log("twitter handler [DONE]")
      else
        log("twitter handler [SKIPPED]")
      end

      locations
    end

    private

    def create_request_connection
      Faraday.new(
        url: @portal.api_base_url,
        headers: @portal.request_headers,
        ssl: { verify: false }
      ) do |faraday|
        faraday.response :logger, Turbovax.logger,
                         Turbovax.faraday_logging_config
        faraday.adapter Faraday.default_adapter
      end
    end

    def make_request
      request_type = @portal.request_http_method
      path = @portal.api_path
      # query_params = {}
      query_params = @portal.api_query_params(@extra_params)

      case request_type
      when Turbovax::Constants::GET_REQUEST_METHOD
        @conn.get(path) do |req|
          # only set params if they are present, otherwise this will overwrite any string query
          # param values that are existing in the url path
          req.params = query_params if query_params.nil? || query_params != {}
        end
      when Turbovax::Constants::POST_REQUEST_METHOD
        @conn.post(path) do |req|
          # only set params if they are present, otherwise this will overwrite any string query
          # param values that are existing in the url path
          req.params = query_params if query_params.nil? || query_params != {}

          req.body = @portal.request_body(@extra_params)
        end
      else
        raise Turbovax::InvalidRequestTypeError
      end
    end

    def log(message)
      Turbovax.logger.info("[#{self.class}] #{message}")
    end
  end
end
