module Turbovax
  class DataFetcher
    DEFAULT_REQUEST_TIMEOUT = 5.seconds

    def initialize(portal, date: nil)
      @portal = portal
      @date = date
      @conn = create_request_connection
    end

    def execute!
      response = make_request
    end

    private

    def create_request_connection
      Faraday.new(
        url: @portal.api_base_url,
        headers: @portal.headers,
        ssl: { verify: false },
      ) do |connection|
        connection.options.timeout = @portal.request_timeout || DEFAULT_REQUEST_TIMEOUT
      end
    end
  end

  def make_request
    request_type = @conn.request_type
    path = @portal.api_path

    if request_type == :get
      @conn.get(path)
    else
      @conn.post(path) do |req|
        req.body = @portal.request_body
      end
    end
  end
end
