# frozen_string_literal: true

require "twitter"

module Turbovax
  module Twitter
    # Helper class that wraps around Twitter gem
    class Client
      def self.client
        @client ||= Twitter::REST::Client.new do |config|
          config.consumer_key        = Turbovax.twitter_credentials[:consumer_key]
          config.consumer_secret     = Turbovax.twitter_credentials[:consumer_secret]
          config.access_token        = Turbovax.twitter_credentials[:access_token]
          config.access_token_secret = Turbovax.twitter_credentials[:access_token_secret]
        end
      end

      def self.send_tweet(message, reply_to_id: nil)
        client.update(message, in_reply_to_status_id: reply_to_id)
      end
    end
  end
end
