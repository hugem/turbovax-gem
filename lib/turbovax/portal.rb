# frozen_string_literal: true

require "json"

module Turbovax
  class Portal
    class << self
      # @!macro [attach] definte_parameter
      #   @method $1
      #   $3
      #   @return [$2]
      #   @example $4
      #     $5
      def self.definte_parameter(
        attribute, _doc_return_type, _explanation = nil, _explanation = nil,
        _example = nil
      )
        # metaprogramming magic so that
        #   1) attributes can be defined via DSL
        #   2) attributes can be fetched when method is called without any parameters
        #   3) attributes can saved static variables or blocks that can be called (for dynamic)
        # might be better to refactor in the future
        define_method attribute do |argument = nil, &block|
          variable = nil
          block_exists =
            begin
              variable = instance_variable_get("@#{attribute}")
              variable.is_a?(Proc)
            rescue StandardError
              false
            end

          if !variable.nil?
            block_exists ? variable.call(argument) : variable
          else
            instance_variable_set("@#{attribute}", argument || block)
          end
        end
      end

      definte_parameter :name, String, "Full name of portal", "Name",
                        "'New York City Vaccine Website'"
      definte_parameter :key, String, "Unique identifier for portal", "Key", "'nyc_vax'"
      definte_parameter :url,
                        String, "Link to public facing website", "Full URL", "'https://www.turbovax.info/'"

      definte_parameter :request_headers, Hash, "Key:value mapping of HTTP request headers",
                        "Specify user agent and cookies", "{ 'user-agent': 'Mozilla/5.0', 'cookies': 'ABC' }"
      definte_parameter :request_http_method, Symbol,
                        "Turbovax::Constants::GET_REQUEST_METHOD or Turbovax::Constants::POST_REQUEST_METHOD"
      definte_parameter :api_url, String, "Full API URL", "Example Turbovax endpoint",
                        "'https://api.turbovax.info/v1/dashboard'"
      definte_parameter :api_url_variables, Hash,
                        "Hash or block that is interpolated ",
                        '
          api_url_variables do |extra_params|
            {
              site_id: NAME_TO_ID_MAPPING[extra_params[:name]],
              date: extra_params.strftime("%F"),
            }
          end

          #  before api_url_variables interpolation
          api_url "https://api.turbovax.info/v1/sites/%{site_id}/${date}"

          #  after api_url_variables interpolation
          api_url "https://api.turbovax.info/v1/sites/8888/2021-08-08"
        '
      # definte_parameter :request_body, Hash,
      #                   "Hash (or block evaluates to a hash) that is used to in a POST request",
      #                   '
      #     request_body do |extra_params|
      #       {
      #         site_id: NAME_TO_ID_MAPPING[extra_params[:name]],
      #         date: extra_params.strftime("%F"),
      #       }
      #     end
      #   '

      # Block that will called after raw data is fetched from API. Must return list of Location
      # instances
      # @param [Array] args passed from [Turbovax::DataFetcher]
      # @param [Block] block stored as a class instance variable
      # @return [Array<Turbovax::Location>]
      # @example Parse API responses from turbovax.info
      #     parse_response do |response|
      #       response_json = JSON.parse(response)
      #       response_json["locations"].map do |location|
      #         Turbovax::Location.new(
      #           name: location["name"],
      #           time_zone: "America/New_York",
      #           data: {
      #             is_available: location["is_available"],
      #             appointment_count: location["appointments"]["count"],
      #             appointments: [{
      #               time: "2021-04-19T17:21:15-04:00",
      #             }]
      #           }
      #         )
      #       end
      #     end
      def parse_response(*args, &block)
        if args.size.positive? && !@parse_response.nil?
          @parse_response.call(*args)
        elsif !block.nil?
          @parse_response = block
        else
          {}
        end
      end

      # Block that will be executed and then appended to API url path. The extra_params variable is
      # provided by Turbovax::DataFetcher.
      # When specified, this will overwrite any query string that is already present in api_url
      #
      # @param [Array] args passed from [Turbovax::DataFetcher]
      # @param [Block] block stored as a class instance variable
      # @return [Hash]
      # @example Append date and noCache to URL
      #   # result: /path?date=2021-08-08&noCache=0.123
      #   api_query_params do |extra_params|
      #     {
      #       date: extra_params[:date].strftime("%F"),
      #       noCache: rand,
      #     }
      #   end
      def api_query_params(*args, &block)
        if args.size.positive? && !@api_query_params.nil?
          @api_query_params.call(*args)
        elsif !block.nil?
          @api_query_params = block
        else
          {}
        end
      end

      def request_body(*args, &block)
        if args.size.positive? && !@request_body.nil?
          @request_body.call(*args)
        elsif !block.nil?
          @request_body = block
        else
          {}.to_json
        end
      end

      # Returns base API URL (used when creating Faraday connection)
      def api_base_url
        "#{api_uri_object.scheme}://#{api_uri_object.hostname}"
      end

      # Returns API URL path (used when making Faraday requests)
      def api_path
        "#{api_uri_object.path}?#{api_uri_object.query}"
      end

      # Calls parse_response and assigns portal to each location so user doesn't need to do
      # this by themselves
      def parse_response_with_portal(response, extra_params)
        parse_response(response, extra_params).map do |location|
          location.portal ||= self
          location
        end
      end

      private

      def api_uri_object
        @api_uri_object ||= URI(api_url % api_url_variables)
      end
    end
  end
end
