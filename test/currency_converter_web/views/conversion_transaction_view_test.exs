defmodule CurrencyConverterWeb.ConversionTransactionViewTest do
  use CurrencyConverterWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  alias CurrencyConverterWeb.ConversionTransactionView

  test "renders index.json" do
    source_currency = Enum.random(["BRL", "USD", "EUR", "JPY"])

    conversion_transaction = %{
      id: Ecto.UUID.generate(),
      user_id: Ecto.UUID.generate(),
      source_currency: source_currency,
      target_currency: Enum.random(["BRL", "USD", "EUR", "JPY"]),
      source_value: Money.new!(Enum.random(1..10), source_currency),
      exchange_rate: Decimal.new(to_string(:rand.uniform())),
      updated_at: DateTime.utc_now(),
      inserted_at: DateTime.utc_now()
    }

    conversion_transactions = [conversion_transaction]

    %{
      id: id,
      user_id: user_id,
      source_currency: source_currency,
      target_currency: target_currency,
      source_value: source_value,
      exchange_rate: exchange_rate,
      updated_at: updated_at,
      inserted_at: inserted_at
    } = conversion_transaction

    assert %{
             data: [
               %{
                 id: ^id,
                 user_id: ^user_id,
                 source_currency: ^source_currency,
                 target_currency: ^target_currency,
                 source_value: ^source_value,
                 exchange_rate: ^exchange_rate,
                 updated_at: ^updated_at,
                 inserted_at: ^inserted_at
               }
             ]
           } =
             render(ConversionTransactionView, "index.json",
               conversion_transactions: conversion_transactions
             )
  end

  test "renders create.json" do
    source_currency = Enum.random(["BRL", "USD", "EUR", "JPY"])
    target_currency = Enum.random(["BRL", "USD", "EUR", "JPY"])

    conversion_transaction = %{
      id: Ecto.UUID.generate(),
      user_id: Ecto.UUID.generate(),
      source_currency: source_currency,
      target_currency: target_currency,
      source_value: Money.new!(Enum.random(1..10), source_currency),
      target_value: Money.new!(Enum.random(1..10), target_currency),
      exchange_rate: Decimal.new(to_string(:rand.uniform())),
      updated_at: DateTime.utc_now(),
      inserted_at: DateTime.utc_now()
    }

    %{
      id: id,
      user_id: user_id,
      source_currency: source_currency,
      target_currency: target_currency,
      source_value: source_value,
      target_value: target_value,
      exchange_rate: exchange_rate,
      updated_at: updated_at,
      inserted_at: inserted_at
    } = conversion_transaction

    assert %{
             data: %{
               id: ^id,
               user_id: ^user_id,
               source_currency: ^source_currency,
               target_currency: ^target_currency,
               source_value: ^source_value,
               target_value: ^target_value,
               exchange_rate: ^exchange_rate,
               updated_at: ^updated_at,
               inserted_at: ^inserted_at
             }
           } =
             render(ConversionTransactionView, "create.json",
               conversion_transaction: conversion_transaction
             )
  end
end
