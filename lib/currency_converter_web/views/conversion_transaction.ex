defmodule CurrencyConverterWeb.ConversionTransactionView do
  use CurrencyConverterWeb, :view

  def render("index.json", %{conversion_transactions: conversion_transactions}) do
    %{
      data:
        render_many(conversion_transactions, __MODULE__, "conversion_transaction.json",
          as: :conversion_transaction
        )
    }
  end

  def render("create.json", %{conversion_transaction: conversion_transaction}) do
    %{
      data:
        render_one(conversion_transaction, __MODULE__, "conversion_transaction.json",
          as: :conversion_transaction
        )
    }
  end

  def render("conversion_transaction.json", %{conversion_transaction: conversion_transaction}) do
    Map.take(conversion_transaction, [
      :id,
      :user_id,
      :source_currency,
      :target_currency,
      :source_value,
      :target_value,
      :exchange_rate,
      :updated_at,
      :inserted_at
    ])
  end
end
