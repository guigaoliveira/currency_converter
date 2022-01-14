defmodule CurrencyConverter do
  @moduledoc """
  Currency Converter Context
  """

  alias CurrencyConverter.ExchangeRates

  @spec convert(Decimal.decimal(), String.t(), String.t()) ::
          {:ok, %{cross_rate: Decimal.t(), total: Money.t()}}
  def convert(
        value,
        source_currency,
        target_currency
      ) do
    with {:ok, source_currency_exchange_rate} <- ExchangeRates.get(source_currency),
         {:ok, target_currency_exchange_rate} <- ExchangeRates.get(target_currency) do
      # we don't use Money.cross_rate!/3 to do cross rate
      # because we would need to use String.to_atom/1 for this

      cross_rate =
        source_currency_exchange_rate
        |> Decimal.new()
        |> Decimal.div(Decimal.new(target_currency_exchange_rate))

      total = value |> Decimal.new() |> Decimal.mult(cross_rate)

      {:ok, %{total: Money.new!(target_currency, total), cross_rate: cross_rate}}
    end
  end
end
