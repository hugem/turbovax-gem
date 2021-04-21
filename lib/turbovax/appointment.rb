# frozen_string_literal: true

require "active_support/all"

module Turbovax
  # Class that encapsulates a singular appointment
  class Appointment
    # @return [DateTime]
    attr_accessor :time
    # @return [String]
    attr_accessor :time_zone
    # @return [Boolean]
    attr_accessor :is_second_dose
    # @return [String]
    attr_accessor :vaccine_type

    # @param params hash mapping of attribute => value
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

    # If time_zone is set on instance, returns appointment time in time zone
    # @return [DateTime]
    def time_in_time_zone
      time_zone ? time.in_time_zone(time_zone) : time
    end

    private

    def <=>(other)
      time <=> other.time
    end
  end
end
