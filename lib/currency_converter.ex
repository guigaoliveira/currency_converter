defmodule CurrencyConverter do
  @moduledoc """
  Currency Converter Context
  """

  @spec convert(number, number, number) :: %{cross_rate: float, total: float}
  def convert(value, source_currency_exchange_rate, target_currency_exchange_rate) do
    cross_rate = source_currency_exchange_rate / target_currency_exchange_rate
    total = value * cross_rate

    %{total: total, cross_rate: cross_rate}
  end
end
