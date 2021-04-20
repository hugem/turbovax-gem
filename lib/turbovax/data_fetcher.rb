require "date"
require "faraday"

module Turbovax
  class DataFetcher
    DEFAULT_REQUEST_TIMEOUT = 5

    def initialize(portal, twitter_handler: nil, date: nil)
      @portal = portal
      @date = date || DateTime.now
      @conn = create_request_connection
      @twitter_handler = twitter_handler
    end

    def execute!
      response = make_request
      locations = @portal.parse_response(response.body)

      @twitter_handler.new(locations).execute! if @twitter_handler

      locations
    end

    private

    def create_request_connection
      Faraday.new(
        url: @portal.api_base_url,
        headers: @portal.request_headers,
        ssl: { verify: false }
      )
    end

    def make_request
      request_type = @portal.request_http_method
      path = @portal.api_path

      if request_type == :get
        # @conn.get(path)
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
  end
end

# reload!; t = Turbovax::TestPortal; DataFetcher.new(t).execute!
# reload!; e = Turbovax::EasyTestPortal; Turbovax::DataFetcher.new(e, twitter_handler: Turbovax::Twitter::IndividualLocationHandler).execute!
