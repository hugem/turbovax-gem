require "json"

module Turbovax
  class Portal
    ATTRIBUTES = %w[key name url api_url url_params
                    request_http_method request_headers request_cookies request_timeout
                    parse_response]
    # dynamic_api_url_params query_params

    class << self
      ATTRIBUTES.each do |attribute|
        define_method attribute do |argument = nil, &block|
          variable = nil
          block_exists =
            begin
              variable = class_variable_get("@@#{attribute}")
              variable.is_a?(Proc)
            rescue StandardError => e
              false
            end

          if !variable.nil?
            block_exists ? variable.call(argument) : variable
          else
            class_variable_set("@@#{attribute}", argument || block)
          end
        end
      end

      def api_query_params(&block)
        if block.nil?
          @@api_query_params.call
        else
          @@api_query_params = block
        end
      end

      def request_body(date: nil, &block)
        if block.nil?
          @@request_body.call(date)
        else
          @@request_body = block
        end
      end

      def api_dynamic_variables(&block)
        if block.nil?
          @@api_dynamic_variables.call
        else
          @@api_dynamic_variables = block
        end
      end

      def parse_response(response = nil, &block)
        if block.nil?
          @@parse_response.call(response)
        else
          @@parse_response = block
        end
      end

      # REQUIRED_METHODS = %W(parse_response)
      # REQUIRED_METHODS.each do |method|
      #   define_method "#{method}" do
      #     raise NotImplementedError
      #   end
      # end

      # ATTRIBUTES_WITH_DEFAULTS = %W(dynamic_api_url_params query_params)
      # ATTRIBUTES_WITH_DEFAULTS.each do |attribute|
      #   attr_writer attribute
      #   define_method attribute do
      #     instance_variable_get("@#{attribute}") || {}
      #   end
      # end

      def api_base_url
        "#{api_uri_object.scheme}://#{api_uri_object.hostname}"
      end

      def api_path
        api_uri_object.path
      end

      private

      def api_uri_object
        @@api_uri_object ||= URI(api_url % api_dynamic_variables)
      end
    end

    api_query_params do
      {}
    end

    api_dynamic_variables do
      {}
    end

    #   TO_JSON_ATTRIBUTES = %W(key name url)

    #   def to_json
    #     TO_JSON_ATTRIBUTES.each_with_object({}) do |attribute, to_return|
    #       to_return[attribute] = self.send(attribute)
    #     end
    #   end
  end
end
