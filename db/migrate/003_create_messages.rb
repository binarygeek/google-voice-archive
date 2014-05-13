Sequel.migration do
  transaction

  up do
    create_table :messages do
      primary_key :id
      Integer :sender_id
      Integer :contact_id
      String :text
      Text :sent_at
    end
  end

  down do
    drop_table :messages
  end
end
