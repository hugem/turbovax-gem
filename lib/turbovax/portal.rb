require "json"

module Turbovax
  class Portal
    ATTRIBUTES = %w[
      key name url api_url url_params
      request_http_method request_headers request_cookies request_timeout
      parse_response
    ].freeze

    class << self
      ATTRIBUTES.each do |attribute|
        define_method attribute do |argument = nil, &block|
          variable = nil
          block_exists =
            begin
              variable = instance_variable_get("@#{attribute}")
              variable.is_a?(Proc)
            rescue StandardError => e
              false
            end

          if !variable.nil?
            block_exists ? variable.call(argument) : variable
          else
            instance_variable_set("@#{attribute}", argument || block)
          end
        end
      end

      def api_query_params(&block)
        if block.nil?
          @api_query_params.call
        else
          @api_query_params = block
        end
      end

      def request_body(date: nil, &block)
        if block.nil?
          @request_body.call(date)
        else
          @request_body = block
        end
      end

      def api_dynamic_variables(&block)
        if block.nil?
          @api_dynamic_variables.call
        else
          @api_dynamic_variables = block
        end
      end

      def parse_response(response = nil, &block)
        if block.nil?
          @parse_response.call(response)
        else
          @parse_response = block
        end
      end

      def api_base_url
        "#{api_uri_object.scheme}://#{api_uri_object.hostname}"
      end

      def api_path
        api_uri_object.path
      end

      private

      def api_uri_object
        @api_uri_object ||= URI(api_url % api_dynamic_variables)
      end
    end

    api_query_params do
      {}
    end

    api_dynamic_variables do
      {}
    end
  end
end
