defmodule CurrencyConverter.ConversionTransactions.Inputs.ConversionTransactionInput do
  @moduledoc """
  Schema for conversion transaction.
  """

  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :user_id, :binary
    field :source_currency, :string
    field :target_currency, :string
    field :source_value, :decimal
  end

  @spec validate_index(Ecto.Schema.t() | Ecto.Changeset.t() | {map, map}, map) ::
          Ecto.Changeset.t()
  def validate_index(struct_or_changeset \\ %__MODULE__{}, attrs) do
    required_fields = [
      :user_id
    ]

    struct_or_changeset
    |> cast_and_validate_required_fields(attrs, required_fields)
    |> validate_uuid(:user_id)
  end

  @spec validate_create(Ecto.Schema.t() | Ecto.Changeset.t() | {map, map}, map) ::
          Ecto.Changeset.t()
  @doc """
  Validates creation of a conversion transaction
  """
  def validate_create(struct_or_changeset \\ %__MODULE__{}, attrs) do
    required_fields = [
      :user_id,
      :source_currency,
      :target_currency,
      :source_value
    ]

    cast_and_validate_required_fields(struct_or_changeset, attrs, required_fields)
    |> validate_currency(:source_currency)
    |> validate_currency(:target_currency)
  end

  defp cast_and_validate_required_fields(struct_or_changeset, attrs, required_fields) do
    struct_or_changeset
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
  end

  defp validate_uuid(%Ecto.Changeset{} = changeset, field) do
    case Ecto.UUID.cast(changeset.changes[field]) do
      {:ok, _} ->
        changeset

      :error ->
        add_error(changeset, field, "must to be an uuid")
    end
  end

  defp validate_currency(%Ecto.Changeset{} = changeset, field) do
    changeset
    |> validate_length(field, max: 3)
    |> validate_inclusion(field, config_worker(:supported_currencies))
  end

  defp config_worker(key) do
    Application.fetch_env!(:currency_converter, CurrencyConverter.ExchangeRatesWorker)
    |> Keyword.fetch!(key)
  end
end
