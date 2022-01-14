defmodule CurrencyConverter.ConversionTransactions.Inputs.ConversionTransactionInput do
  @moduledoc """
  Schema for conversion transaction.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias CurrencyConverter.Utils.EctoTypes.SortType
  alias CurrencyConverter.Utils.Validations.SortValidation

  embedded_schema do
    field :user_id, :binary
    field :source_currency, :string
    field :target_currency, :string
    field :source_value, :decimal

    field :offset, :integer, default: 0
    field :limit, :integer, default: 20

    field :inserted_at, :utc_datetime_usec
    field :inserted_at_start, :utc_datetime_usec
    field :inserted_at_end, :utc_datetime_usec

    field :sort, SortType
  end

  @spec validate_index(Ecto.Schema.t() | Ecto.Changeset.t() | {map, map}, map) ::
          Ecto.Changeset.t()
  def validate_index(struct_or_changeset \\ %__MODULE__{}, attrs) do
    required_fields = [
      :user_id
    ]

    optional_fields = [:limit, :offset]

    struct_or_changeset
    |> cast(attrs, required_fields ++ optional_fields)
    |> validate_required(required_fields)
    |> validate_number(:offset, greater_than_or_equal_to: 0)
    |> validate_number(:limit, greater_than: 0, less_than_or_equal_to: 100)
    |> validate_uuid(:user_id)
    |> SortValidation.validate(["inserted_at"])
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

    struct_or_changeset
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> validate_currency(:source_currency)
    |> validate_currency(:target_currency)
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