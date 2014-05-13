Sequel.migration do
  transaction

  up do
    create_table :contacts do
      primary_key :id
      Integer :account_id
      String :name
      String :number
    end
  end

  down do
    drop_table :contacts
  end
end