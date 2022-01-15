defmodule CurrencyConverter.ConversionTransactions do
  @moduledoc """
  Conversion Transactions Context
  """

  import Ecto.Query

  alias CurrencyConverter.ConversionTransactions.Schemas.ConversionTransaction
  alias CurrencyConverter.Repo
  alias CurrencyConverter.Utils.DataManipulation

  @doc """
  List all Conversion Transactions by user id
  """
  @spec all_by_user(%{:user_id => String.t(), optional(any) => any}) :: [Ecto.Schema.t()]
  def all_by_user(%{user_id: user_id} = params) do
    fields = ConversionTransaction.__schema__(:fields)

    ConversionTransaction
    |> select([p], map(p, ^fields))
    |> where(user_id: ^user_id)
    |> DataManipulation.apply_operations(params)
    |> Repo.all()
  end

  @doc """
  Insert a new Conversion Transaction into db
  """
  @spec create(map) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    %ConversionTransaction{} |> ConversionTransaction.changeset(params) |> Repo.insert()
  end
end
