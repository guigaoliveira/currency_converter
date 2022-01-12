defmodule CurrencyConverter.ConversionTransactions do
  @moduledoc """
  Conversion Transactions Context
  """

  import Ecto.Query

  alias CurrencyConverter.Repo
  alias CurrencyConverter.ConversionTransactions.Schemas.ConversionTransaction

  @doc """
  List all Conversion Transactions by user id
  """
  def all_by_user(%{user_id: user_id}) do
    fields = ConversionTransaction.__schema__(:fields)

    ConversionTransaction
    |> select([p], map(p, ^fields))
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  @doc """
  Insert a new Conversion Transaction into db
  """
  def create(params) do
    %ConversionTransaction{} |> ConversionTransaction.changeset(params) |> Repo.insert()
  end
end
