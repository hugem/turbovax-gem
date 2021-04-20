module Turbovax
  class Location
    ATTRIBUTES = %w[id name portal portal_id address area zipcode latitude longitude time_zone vaccine_brands appointments
                    vaccine_type_data appointments
                    data
                    is_available_data
                    appointment_data
                    appointment_count_data
                    metadata]

    ATTRIBUTES.each do |attribute|
      attr_accessor attribute
    end

    def initialize(**params)
      params.each do |attribute, value|
        send("#{attribute}=", value)
      end
    end

    def is_available?
      data_hash[:is_available] || appointment_count > 0
    end

    def vaccine_types
      data_hash[:vaccine_types] || appointments.map(&:vaccine_type).uniq
    end

    def appointments
      Array(data_hash[:appointments]).map do |appointment|
        if appointment.is_a?(Turbovax::Appointment)
          appointment
        else
          Turbovax::Appointment.new(appointment)
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

    # def to_h
    #   ATTRIBUTES.each_with_object({}) do |attribute_name, memo|
    #     memo[attribute_name] = send(attribute_name)
    #   end
    # end

    # def appointment_summary
    #   appointment_dates = appointments.each do |appointment|

    #   end

    #   {
    #     dates: [],

    #   }
    # end
  end
end
