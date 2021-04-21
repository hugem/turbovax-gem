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
      definte_parameter :request_http_method, Symbol, ":get or :post"
      definte_parameter :api_url, String, "API endpoint", "'https://api.turbovax.info/v1/dashboard'"
      definte_parameter :api_query_params, Hash,
                        "Key:value mapping that will be encoded + appended to URL when making the request",
                        "{ page: 1 }"
      definte_parameter :api_dynamic_variables, Hash,
                        "Hash or block that is interpolated ",
                        '
          api_dynamic_variables do |data_fetcher_params|
            {
              site_id: NAME_TO_ID_MAPPING[data_fetcher_params[:name]],
              date: data_fetcher_params.strftime("%F"),
            }
          end

          #  before api_dynamic_variables interpolation
          api_url "https://api.turbovax.info/v1/sites/%{site_id}/${date}"

          #  after api_dynamic_variables interpolation
          api_url "https://api.turbovax.info/v1/sites/8888/2021-08-08"
        '
      definte_parameter :request_body, Hash,
                        "Hash (or block evaluates to a hash) that is used to in a POST request",
                        '
          request_body do |data_fetcher_params|
            {
              site_id: NAME_TO_ID_MAPPING[data_fetcher_params[:name]],
              date: data_fetcher_params.strftime("%F"),
            }
          end
        '

      # Block that will called after raw data is fetched from API. Must return list of Location
      # instances
      # @param [String] response string passed to the block when it is called
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
      def parse_response(response = nil, &block)
        if block.nil?
          @parse_response.call(response)
        else
          @parse_response = block
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
      def parse_response_with_portal(response)
        parse_response(response).map do |location|
          location.portal ||= self
          location
        end
      end

      private

      def api_uri_object
        @api_uri_object ||= URI(api_url % api_dynamic_variables)
      end
    end

    # set default values
    api_query_params do
      {}
    end

    # set default values
    api_dynamic_variables do
      {}
    end
  end
end
