module Turbovax
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
    # ID that was specified by the portal
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
    attr_accessor :time_zone
    # @return [Hash]
    # Use to specify appointments, appointment_count, available, vaccine_types
    attr_accessor :data
    # @return [Hash]
    # Use to add any metadata
    attr_accessor :metadata

    def initialize(**params)
      params.each do |attribute, value|
        send("#{attribute}=", value)
      end
    end

    def available
      data_hash[:is_available] || appointment_count.positive?
    end

    def vaccine_types
      data_hash[:vaccine_types] || appointments.map(&:vaccine_type).uniq
    end

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
