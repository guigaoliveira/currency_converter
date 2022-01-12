defmodule CurrencyConverterWeb.ConversionTransactionControllerTest do
  use CurrencyConverterWeb.ConnCase

  alias CurrencyConverter.{ConversionTransactions, ExchangeRates}
  alias CurrencyConverterWeb.Router.Helpers, as: Routes

  describe "index/2" do
    setup [:create_conversion_transactions]

    test "list all conversion transactions by user id", %{
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

  describe "create/2" do
    setup [:create_exchange_rates]

    test "create a new conversion transaction", %{
      conn: conn
    } do
      params = %{
        user_id: Ecto.UUID.generate(),
        source_currency: Enum.random(["BRL", "USD", "EUR", "JPY"]),
        target_currency: Enum.random(["BRL", "USD", "EUR", "JPY"]),
        source_value: Enum.random(1..10)
      }

      %{
        user_id: user_id,
        source_currency: source_currency,
        target_currency: target_currency,
        source_value: source_value
      } = params

      conn =
        post(
          conn,
          Routes.conversion_transaction_path(conn, :create),
          params
        )

      assert %{
               "data" => %{
                 "id" => _id,
                 "user_id" => ^user_id,
                 "source_currency" => ^source_currency,
                 "target_currency" => ^target_currency,
                 "source_value" => ^source_value,
                 "target_value" => _target_value,
                 "exchange_rate" => _exchange_rate,
                 "inserted_at" => _inserted_at,
                 "updated_at" => _updated_at
               }
             } = json_response(conn, 200)
    end
  end

  defp create_conversion_transactions(_) do
    conversion_transactions = fixture(:conversion_transactions)
    %{conversion_transactions: conversion_transactions}
  end

  defp create_exchange_rates(_) do
    exchange_rates = fixture(:exchange_rates)
    %{exchange_rates: exchange_rates}
  end

  defp fixture(:conversion_transactions) do
    {:ok, struct} =
      ConversionTransactions.create(%{
        user_id: Ecto.UUID.generate(),
        source_currency: Enum.random(["BRL", "USD", "EUR", "JPY"]),
        target_currency: Enum.random(["BRL", "USD", "EUR", "JPY"]),
        source_value: Enum.random(1..10),
        exchange_rate: :rand.uniform()
      })

    struct
  end

  defp fixture(:exchange_rates) do
    rates = %{
      "BRL" => Enum.random(1..10),
      "USD" => Enum.random(1..10),
      "EUR" => Enum.random(1..10),
      "JPY" => Enum.random(1..10)
    }

    ExchangeRates.insert(rates)
    rates
  end
end
