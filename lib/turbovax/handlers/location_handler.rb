# frozen_string_literal: true

require "twitter"

module Turbovax
  module Handlers
    # Given a list of locations, tweet appointment info for each location
    class LocationHandler
      def initialize(locations)
        @locations = locations
      end

      def execute!
        count = 0
        @locations.each do |location|
          next if count >= max_location_limit

          count += 1 if handle_location(location)
        end
      end

      # Max locations to tweet at a given time
      def max_location_limit
        2
      end

      # Max number of days included in a tweet
      def day_limit
        3
      end

      # Max number of appointment times included per day
      def daily_appointment_limit
        3
      end

      # Format of each individual date. See APIdoc for format
      # https://apidock.com/ruby/DateTime/strftime
      # @example Datetime to default time format
      #   Wed, 21 Apr 2021 09:23:15 -0400 => Apr 21
      def date_format
        "%b %-e"
      end

      # Format of each individual appointment time. See APIdoc for format
      # https://apidock.com/ruby/DateTime/strftime
      # @example Datetime to default time format
      #   Wed, 21 Apr 2021 09:23:15 -0400 => 9:23AM
      def appointment_time_format
        "%-l:%M%p"
      end

      # @return [Boolean]
      # Override this method to to add caching logic
      def should_tweet_for_location(location)
        location.available
      end

      private

      def handle_location(location)
        return false unless should_tweet_for_location(location)

        text = format_tweet(location)

        send_tweet(text)
        true
      end

      def send_tweet(text)
        Turbovax::TwitterClient.send_tweet(text)
      end

      def format_tweet(location)
        to_join = []

        portal = location.portal
        appointment_count = location.appointment_count ? "#{location.appointment_count} appts" : nil

        summary_string = "[#{join(portal.name, location.area, delimiter: " · ")}] "
        summary_string += join(location.name, appointment_count, delimiter: ": ")
        to_join << summary_string

        to_join << format_appointments(location)
        to_join << portal.public_url

        to_join.join("\n\n")
      end

      def format_appointments(location)
        to_join = []

        appointments_by_day =
          group_appointments_by_day(location.appointments.sort)

        appointments_by_day.each.with_index do |(day, appointments), index|
          next if index >= day_limit

          to_join << format_appointments_for_day(day, appointments)
        end

        to_join.join("\n")
      end

      def group_appointments_by_day(appointments)
        appointments.each_with_object({}) do |appointment, memo|
          day = appointment.time_in_time_zone.strftime(date_format)

          memo[day] ||= []
          memo[day] << appointment
        end
      end

      def format_appointments_for_day(day_string, appointments)
        use_extra_appointment_count = appointments.size > daily_appointment_limit
        extra_appointment_count = appointments.size - daily_appointment_limit

        sorted_times = appointments.first(daily_appointment_limit).sort.map do |appointment|
          appointment.time_in_time_zone.strftime(appointment_time_format)
        end

        time_string = sorted_times.join(", ")
        time_string += " + #{extra_appointment_count}" if use_extra_appointment_count

        "#{day_string}: #{time_string}"
      end

      def join(*args, delimiter:)
        args.compact.join(delimiter)
      end
    end
  end
end
