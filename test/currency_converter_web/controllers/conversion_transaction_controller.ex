defmodule CurrencyConverterWeb.ConversionTransactionControllerTest do
  use CurrencyConverterWeb.ConnCase

  alias CurrencyConverter.ConversionTransactions
  alias CurrencyConverterWeb.Router.Helpers, as: Routes

  describe "index" do
    setup [:create_conversion_transactions]

    test "lists all numbers in asc order when order_by parameter is not passed", %{
      conn: conn,
      conversion_transactions: conversion_transactions
    } do
      %{
        user_id: user_id,
        source_currency: source_currency,
        target_currency: target_currency,
        source_value: source_value,
        exchange_rate: exchange_rate
      } = conversion_transactions

      conn =
        get(
          conn,
          Routes.conversion_transaction_path(conn, :index, user_id)
        )

      assert %{
               "data" => [
                 %{
                   "id" => _id,
                   "user_id" => ^user_id,
                   "source_currency" => ^source_currency,
                   "target_currency" => ^target_currency,
                   "source_value" => ^source_value,
                   "exchange_rate" => ^exchange_rate,
                   "inserted_at" => _inserted_at,
                   "updated_at" => _updated_at
                 }
               ]
             } = json_response(conn, 200)
    end
  end

  defp create_conversion_transactions(_) do
    conversion_transactions = fixture(:conversion_transactions)
    %{conversion_transactions: conversion_transactions}
  end

  def fixture(:conversion_transactions) do
    {:ok, struct} =
      ConversionTransactions.create(%{
        user_id: Ecto.UUID.generate(),
        source_currency: Enum.random(["BRL", "USD", "EUR", "JPY"]),
        target_currency: Enum.random(["BRL", "USD", "EUR", "JPY"]),
        source_value: Enum.random(1..100),
        exchange_rate: :rand.uniform()
      })

    struct
  end
end
