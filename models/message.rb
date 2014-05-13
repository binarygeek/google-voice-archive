class Message < Sequel::Model
  many_to_one :contact
  many_to_one :sender, class: Contact, key: :sender_id
end