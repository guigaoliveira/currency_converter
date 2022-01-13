defmodule CurrencyConverterWeb.ConversionTransactionController do
  use CurrencyConverterWeb, :controller

  alias CurrencyConverter.{ConversionTransactions, ExchangeRates}

  def index(conn, %{"user_id" => user_id}) do
    conversion_transactions = ConversionTransactions.all_by_user(%{user_id: user_id})

    render(conn, "index.json", conversion_transactions: conversion_transactions)
  end

  def create(conn, params) do
    %{
      "source_value" => source_value,
      "source_currency" => source_currency,
      "target_currency" => target_currency
    } = params

    source_value_decimal = Decimal.new(source_value)

    with {:ok, source_currency_exchange_rate} <- ExchangeRates.get(source_currency),
         {:ok, target_currency_exchange_rate} <- ExchangeRates.get(target_currency),
         %{total: target_value, cross_rate: exchange_rate} <-
           CurrencyConverter.convert(
             source_value,
             source_currency_exchange_rate,
             target_currency_exchange_rate
           ),
         {:ok, conversion_transaction} <-
           params
           |> Map.merge(%{
             "exchange_rate" => exchange_rate,
             "source_value" => Money.new!(source_currency, source_value_decimal)
           })
           |> ConversionTransactions.create() do
      render(conn, "create.json",
        conversion_transaction:
          Map.merge(
            conversion_transaction,
            %{
              target_value: target_value,
              source_value: source_value_decimal
            }
          )
      )
    end
  end
end
