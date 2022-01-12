defmodule CurrencyConverter.ConversionTransactions.Schemas.ConversionTransaction do
  @moduledoc """
  Schema for conversion transaction.
  """

  use Ecto.Schema

  import Ecto.Changeset, only: [cast: 3, validate_required: 2]

  @primary_key {:id, :binary_id, autogenerate: true}

  @required [
    :user_id,
    :source_currency,
    :target_currency,
    :source_value,
    :exchange_rate
  ]

  schema "conversion_transactions" do
    field :user_id, :binary_id
    field :source_currency, :string
    field :target_currency, :string
    field :source_value, :integer
    field :exchange_rate, :float

    timestamps(type: :naive_datetime_usec)
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
