defmodule CurrencyConverter.ConversionTransactions.Schemas.ConversionTransaction do
  @moduledoc """
  Schema for conversion transaction.
  """

  use Ecto.Schema

  import Ecto.Changeset, only: [cast: 3, validate_required: 2]

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  @required [
    :user_id,
    :source_currency,
    :target_currency,
    :source_value,
    :exchange_rate
  ]

  schema "conversion_transactions" do
    field :user_id, Ecto.UUID
    field :source_currency, :string
    field :target_currency, :string
    field :source_value, Money.Ecto.Composite.Type
    field :exchange_rate, :decimal

    timestamps(type: :utc_datetime_usec)
  end

  @spec changeset(Ecto.Schema.t() | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def changeset(struct_or_changeset \\ %__MODULE__{}, params) do
    struct_or_changeset
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
