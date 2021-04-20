module Turbovax
  class Appointment
    ATTRIBUTES = %w[time is_second_dose vaccine_type]

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
  end
end
