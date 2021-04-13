require 'datetime'

module Turbovax
  class Location
    ATTRIBUTES = %W(name portal portal_id address city state zipcode latitude longitude time_zone area vaccine_brands appointments
      is_available_override
      metadata)

    ATTRIBUTES.each do |attribute|
      attr_accessor attribute
    end

    def is_available?
      is_available_override || appointments.size > 0
    end

    # def appointment_summary
    #   appointment_dates = appointments.each do |appointment|

    #   end

    #   {
    #     dates: [],

    #   }
    # end
  end
end
