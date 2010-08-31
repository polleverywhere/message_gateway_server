class MessageGateway
  module PhoneNumber
    def sanitize_phone_number(phone)
      sanitized_phone = phone.gsub(/\D/, '')
      sanitized_phone.empty? ? phone : sanitized_phone
    end

    def sanitize_us_phone_number(phone)
      sanitize_phone_number(phone)[/^1?([^10]\d{9})$/, 1] || ""
    end
    
    def canonicalize_phone_number(phone)
      phone = sanitize_phone_number(phone)
      phone[0,0] = '1' if phone.size == 10
      phone.blank? ? nil : phone
    end
    
  end

end