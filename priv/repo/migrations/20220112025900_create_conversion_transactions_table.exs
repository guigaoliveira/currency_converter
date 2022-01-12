defmodule CurrencyConverter.Repo.Migrations.CreateConversionTransactionsTable do
  use Ecto.Migration

  def change do
    create table(:conversion_transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :user_id, :binary_id
      add :source_currency, :string
      add :target_currency, :string
      add :source_value, :integer
      add :exchange_rate, :float

      timestamps(type: :naive_datetime_usec)
    end
  end
end
