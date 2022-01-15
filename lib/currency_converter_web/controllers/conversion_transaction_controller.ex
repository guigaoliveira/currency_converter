defmodule CurrencyConverterWeb.ConversionTransactionController do
  use CurrencyConverterWeb, :controller

  alias CurrencyConverter.ConversionTransactions
  alias CurrencyConverter.ConversionTransactions.Inputs.ConversionTransactionInput

  action_fallback CurrencyConverterWeb.FallbackController

  @doc """
  List all conversion transactions by user id
  """
  def index(conn, params) do
    with {:ok, params} <-
           ConversionTransactionInput.cast_and_validate_index(params) do
      conversion_transactions = ConversionTransactions.all_by_user(params)

      render(conn, "index.json", conversion_transactions: conversion_transactions)
    end
  end

  @doc """
  Creates a new conversion transaction
  """
  def create(conn, params) do
    with {:ok, params} <-
           ConversionTransactionInput.cast_and_validate_create(params),
         {:ok, %{total: target_value, cross_rate: exchange_rate}} <-
           CurrencyConverter.convert(
             params.source_value,
             params.source_currency,
             params.target_currency
           ),
         source_value <- Money.new!(params.source_currency, params.source_value),
         {:ok, conversion_transaction} <-
           params
           |> Map.merge(%{
             exchange_rate: exchange_rate,
             source_value: source_value
           })
           |> ConversionTransactions.create() do
      render(conn, "create.json",
        conversion_transaction:
          Map.merge(
            conversion_transaction,
            %{target_value: target_value, source_value: source_value}
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
