module Turbovax
  class Location
    ATTRIBUTES = %w[id name portal portal_id address area zipcode latitude longitude time_zone vaccine_brands
                    vaccine_type_data
                    data
                    metadata].freeze

    ATTRIBUTES.each do |attribute|
      attr_accessor attribute
    end

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
