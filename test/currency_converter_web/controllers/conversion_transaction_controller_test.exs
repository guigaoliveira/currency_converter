defmodule CurrencyConverterWeb.ConversionTransactionControllerTest do
  use CurrencyConverterWeb.ConnCase

  alias CurrencyConverter.{ConversionTransactions, ExchangeRates}
  alias CurrencyConverterWeb.Router.Helpers, as: Routes

  setup do
    Cachex.clear(:currency_converter)

    :ok
  end

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

      exchange_rate_string = Decimal.to_string(exchange_rate)
      source_value_amount = Decimal.to_string(Money.to_decimal(source_value))

      conn =
        get(
          conn,
          Routes.conversion_transaction_path(conn, :index, user_id,
            offset: 0,
            limit: 20,
            sort: "[\"inserted_at\", \"desc\"]",
            inserted_at_end: DateTime.to_iso8601(DateTime.utc_now())
          )
        )

      assert %{
               "data" => [
                 %{
                   "id" => _id,
                   "user_id" => ^user_id,
                   "source_currency" => ^source_currency,
                   "target_currency" => ^target_currency,
                   "source_value" => %{
                     "amount" => ^source_value_amount,
                     "currency" => ^source_currency
                   },
                   "exchange_rate" => ^exchange_rate_string,
                   "inserted_at" => _inserted_at,
                   "updated_at" => _updated_at
                 }
               ]
             } = json_response(conn, 200)
    end
  end

  describe "index/2 error handling" do
    test "should return a error when user id is not an uuid", %{
      conn: conn
    } do
      conn =
        get(
          conn,
          Routes.conversion_transaction_path(conn, :index, "not_uuid")
        )

      assert %{
               "errors" => [
                 %{"detail" => %{"user_id" => ["must to be an uuid"]}, "status" => 422}
               ]
             } = json_response(conn, 422)
    end
  end

  describe "create/2" do
    setup [:create_exchange_rates]

    test "create a new conversion transaction", %{
      conn: conn
    } do
      params = %{
        user_id: Ecto.UUID.generate(),
        source_currency: Enum.random(config_worker(:supported_currencies)),
        target_currency: Enum.random(config_worker(:supported_currencies)),
        source_value: Decimal.new(to_string(:rand.uniform()))
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

      source_value_amount = to_string(source_value)

      assert %{
               "data" => %{
                 "id" => _id,
                 "user_id" => ^user_id,
                 "source_currency" => ^source_currency,
                 "target_currency" => ^target_currency,
                 "source_value" => ^source_value_amount,
                 "target_value" => _target_value_amount,
                 "exchange_rate" => _exchange_rate,
                 "inserted_at" => _inserted_at,
                 "updated_at" => _updated_at
               }
             } = json_response(conn, 200)
    end
  end

  describe "create/2 error handling" do
    test "should return a error when try to converter a money when exchange rates no exist in cache",
         %{
           conn: conn
         } do
      params = %{
        user_id: Ecto.UUID.generate(),
        source_currency: Enum.random(config_worker(:supported_currencies)),
        target_currency: Enum.random(config_worker(:supported_currencies)),
        source_value: Decimal.new(to_string(:rand.uniform()))
      }

      conn =
        post(
          conn,
          Routes.conversion_transaction_path(conn, :create),
          params
        )

      assert %{
               "errors" => [
                 %{
                   "detail" =>
                     "It is not possible to create a new conversion transaction" <>
                       " because we do not have exchange rates yet to perform this operation",
                   "status" => 500
                 }
               ]
             } = json_response(conn, 500)
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
    source_currency = Enum.random(config_worker(:supported_currencies))
    random_decimal = Decimal.new(to_string(:rand.uniform()))

    {:ok, struct} =
      ConversionTransactions.create(%{
        user_id: Ecto.UUID.generate(),
        source_currency: source_currency,
        target_currency: Enum.random(config_worker(:supported_currencies)),
        source_value: Money.new!(random_decimal, source_currency),
        exchange_rate: random_decimal
      })

    struct
  end

  defp fixture(:exchange_rates) do
    rates =
      Map.new(config_worker(:supported_currencies), fn currency ->
        {currency, to_string(:rand.uniform())}
      end)

    ExchangeRates.insert(rates)
    rates
  end

  defp config_worker(key) do
    Application.fetch_env!(:currency_converter, CurrencyConverter.ExchangeRatesWorker)
    |> Keyword.fetch!(key)
  end
end
