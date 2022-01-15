defmodule CurrencyConverterWeb.ConversionTransactionController do
  use CurrencyConverterWeb, :controller

  alias CurrencyConverter.ConversionTransactions
  alias CurrencyConverter.ConversionTransactions.Inputs.ConversionTransactionInput

  action_fallback CurrencyConverterWeb.FallbackController

  @doc """
  List all conversion transactions by user id
  """
  def index(conn, params) do
    with {:ok, params} <- ConversionTransactionInput.cast_and_validate_index(params) do
      conversion_transactions = ConversionTransactions.all_by_user(params)
      render(conn, "index.json", conversion_transactions: conversion_transactions)
    end
  end

  @doc """
  Creates a new conversion transaction
  """
  def create(conn, params) do
    with {:ok,
          %{
            source_amount: source_amount,
            source_currency: source_currency,
            target_currency: target_currency
          } = params} <-
           ConversionTransactionInput.cast_and_validate_create(params),
         {:ok, %{target_money: target_money, cross_rate: exchange_rate}} <-
           CurrencyConverter.convert(source_amount, source_currency, target_currency),
         source_money <- Money.new!(source_currency, source_amount),
         {:ok, conversion_transaction} <-
           params
           |> Map.merge(%{exchange_rate: exchange_rate, source_money: source_money})
           |> ConversionTransactions.create() do
      conversion_transaction =
        Map.merge(conversion_transaction, %{
          target_money: target_money,
          source_money: source_money
        })

      render(conn, "create.json", conversion_transaction: conversion_transaction)
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
