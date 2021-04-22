# frozen_string_literal: true

module Turbovax
  # Representation of an individual vaccination site
  class Location
    # @return [String]
    # Unique ID for identification purposes
    attr_accessor :id
    # @return [String]
    # Human readable name
    attr_accessor :name
    # @return [Turbovax::Portal]
    attr_accessor :portal
    # @return [String]
    # Portal specific ID
    attr_accessor :portal_id
    # @return [String]
    attr_accessor :area
    # @return [String]
    attr_accessor :street
    # @return [String]
    attr_accessor :zipcode
    # @return [String]
    attr_accessor :latitude
    # @return [String]
    attr_accessor :longitude
    # @return [String]
    # Valid values in https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html
    attr_accessor :time_zone
    # @return [Hash]
    # Use this nested hash to specify appointments, appointment_count, available, vaccine_types
    attr_accessor :data
    # @return [Hash]
    # Use this attribute to add any metadata
    attr_accessor :metadata

    def initialize(**params)
      params.each do |attribute, value|
        send("#{attribute}=", value)
      end
    end

    # @return [Boolean]
    # This can be manually specified via data hash or automatically calculated if
    # appointment_count > 0
    def available
      data_hash[:available] || appointment_count.positive?
    end

    # This can be manually specified via data hash or automatically calculated
    def vaccine_types
      data_hash[:vaccine_types] || appointments.map(&:vaccine_type).uniq
    end

    # Returns a list of appointment instances (which are defined via) data hash
    def appointments
      Array(data_hash[:appointments]).map do |appointment|
        if appointment.is_a?(Turbovax::Appointment)
          appointment.time_zone = time_zone
          appointment
        else
          Turbovax::Appointment.new(appointment.merge(time_zone: time_zone))
        end
      end
    end

    def appointment_count
      data_hash[:appointment_count] || appointments.size
    end

    private

    def data_hash
      data || {}
    end
  end
end
