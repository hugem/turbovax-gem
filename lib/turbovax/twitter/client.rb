# frozen_string_literal: true

require "twitter"

module Turbovax
  module Twitter
    class Client
      def self.client
        @client ||= Twitter::REST::Client.new do |config|
          config.consumer_key        = ENV["TWITTER_API_KEY"]
          config.consumer_secret     = ENV["TWITTER_API_SECRET"]
          config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
          config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
        end
      end

      def self.send_tweet(message, reply_to_id: nil)
        client.update(message, in_reply_to_status_id: reply_to_id)
      end
    end
  end
end
