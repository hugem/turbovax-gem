require "active_support/all"

module Turbovax
  class Appointment
    ATTRIBUTES = %w[time time_zone is_second_dose vaccine_type]

    ATTRIBUTES.each do |attribute|
      attr_accessor attribute
    end

    def initialize(**params)
      params.each do |attribute, value|
        value_to_save =
          if attribute.to_s == "time"
            DateTime.parse(value)
          else
            value
          end

        send("#{attribute}=", value_to_save)
      end
    end

    def time_in_time_zone
      time_zone ? time.in_time_zone(time_zone) : time
    end

    def <=>(other)
      time <=> other.time
    end
  end
end
