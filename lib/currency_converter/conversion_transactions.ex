defmodule CurrencyConverter.ConversionTransactions do
  @moduledoc """
  Conversion Transactions Context
  """

  import Ecto.Query

  alias CurrencyConverter.{ConversionTransactions.Schemas.ConversionTransaction, Repo}
  alias CurrencyConverter.Utils.DataManipulation

  @doc """
  List all Conversion Transactions by user id
  """
  def all_by_user(params) do
    fields = ConversionTransaction.__schema__(:fields)

    ConversionTransaction
    |> select([p], map(p, ^fields))
    |> where(user_id: ^params.user_id)
    |> DataManipulation.apply_operations(params)
    |> Repo.all()
  end

  @doc """
  Insert a new Conversion Transaction into db
  """
  def create(params) do
    %ConversionTransaction{} |> ConversionTransaction.changeset(params) |> Repo.insert()
  end
end
