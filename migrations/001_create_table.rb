require 'sequel'

Sequel.migration do
  up do
    create_table(:urls) do
      primary_key :id
      String :original_url
      Integer :visits, default: 0
    end
  end

  down do
    drop_table(:artists)
  end
end