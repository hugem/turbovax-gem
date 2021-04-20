require 'twitter'

module Turbovax::Twitter
  class IndividualLocationHandler
    def initialize(locations)
      @locations = locations
    end

    def execute!
      @locations.each do |location|
        handle_location
      end
    end

    private

    def handle_location(location)
      if !should_tweet(location)
        # LOG something
      end

      text = format_tweet(location)

      Turbovax::Twitter::Client.send_tweet(text)
    end

    # override to add caching logic
    def should_tweet(location)
      true
    end

    def format_tweet(location)
    to_join = []

    portal = location.portal
    location_count = "#{location.appointment_count} appts"

    # string = "[#{portal.name} · #{location.area}] #{@name}: #{location_count}"
    summary_string = "[#{join(portal.name, portal.location, delimiter: " · ")}] "
    summary_string += join(location.name, location.appointment_count, delimiter: ": ")
    to_join << summary_string

    # format_appointment_times

     #{@name}: #{location_count}"
    to_join << summary[:body]
    to_join << portal.url

    to_join.join("\n\n")
  end

  def join(*args, delimiter:)
    args.compact.join(delimiter)
  end

  def format_location_string(appt_block)
    "#{appt_blo
  end
end
