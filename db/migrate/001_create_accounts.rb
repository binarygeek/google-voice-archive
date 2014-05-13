Sequel.migration do
  transaction

  up do
    create_table :accounts do
      primary_key :id
      String :first_name
      String :last_name
      String :email
      String :crypted_password
      String :role
    end
  end

  down do
    drop_table :accounts
  end
end