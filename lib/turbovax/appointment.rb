module Turbovax
  class Appointment
    ATTRIBUTES = %W(time is_second_dose vaccine_brand)

    ATTRIBUTES.each do |attribute|
      attr_accessor attribute
    end
  end
end
