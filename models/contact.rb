class Contact < Sequel::Model
  many_to_one :account
  one_to_many :message, order: :sent_at
  alias :messages :message

  plugin :validation_helpers

  def validate
    if name.blank? && number.blank?
      errors.add(:name, 'Name or Phone Number must not be blank for the record to be saved')
    end
  end

  def full_name_or_number(reversed=false)
    result = ''
    result = name if name
    result = "+#{number}" if result.blank?
    return result
  end

  def self.find_or_create_by_value(value)
    result = nil
    if /\d+/.match(value)
      result = Contact.find_or_create(number: value)
    else
      result = Contact.find_or_create(name: value)
    end
    result
  end
end