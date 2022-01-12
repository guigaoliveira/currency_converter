defmodule CurrencyConverterWeb.ConversionTransactionController do
  use CurrencyConverterWeb, :controller

  alias CurrencyConverter.ConversionTransactions

  def index(conn, %{"user_id" => user_id}) do
    conversion_transactions = ConversionTransactions.all_by_user(%{user_id: user_id})

    render(conn, "index.json", conversion_transactions: conversion_transactions)
  end

  def create(_conn, _params) do
  end
end
