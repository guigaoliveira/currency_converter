defmodule CurrencyConverterWeb.ConversionTransactionController do
  use CurrencyConverterWeb, :controller

  alias CurrencyConverter.ConversionTransactions
  alias CurrencyConverter.ConversionTransactions.Inputs.ConversionTransactionInput

  action_fallback CurrencyConverterWeb.FallbackController

  def index(conn, params) do
    with %{valid?: true} = validation_result <-
           ConversionTransactionInput.validate_index(params),
         %{user_id: user_id} <- validation_result.changes do
      conversion_transactions = ConversionTransactions.all_by_user(%{user_id: user_id})

      render(conn, "index.json", conversion_transactions: conversion_transactions)
    end
  end

  def create(conn, params) do
    with %{valid?: true, changes: params} <-
           ConversionTransactionInput.validate_create(params),
         {:ok, %{total: target_value, cross_rate: exchange_rate}} <-
           CurrencyConverter.convert(
             params.source_value,
             params.source_currency,
             params.target_currency
           ),
         {:ok, conversion_transaction} <-
           params
           |> Map.merge(%{
             exchange_rate: exchange_rate,
             source_value: Money.new!(params.source_currency, params.source_value)
           })
           |> ConversionTransactions.create() do
      render(conn, "create.json",
        conversion_transaction:
          Map.merge(
            conversion_transaction,
            %{target_value: target_value, source_value: params.source_value}
          )
      )
    else
      {:error, :unavailable_rates} ->
        {:error, 500,
         "It is not possible to create a new conversion transaction" <>
           " because we do not have exchange rates yet to perform this operation"}

      otherwise ->
        otherwise
    end
  end
end
