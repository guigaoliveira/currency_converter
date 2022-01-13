defmodule CurrencyConverter do
  @moduledoc """
  Currency Converter Context
  """

  @spec convert(Decimal.decimal(), number, number) :: %{
          cross_rate: Decimal.t(),
          total: Decimal.t()
        }
  def convert(
        value,
        source_currency_exchange_rate,
        target_currency_exchange_rate
      ) do
    cross_rate =
      source_currency_exchange_rate
      |> Decimal.new()
      |> Decimal.div(Decimal.new(target_currency_exchange_rate))

    total = value |> Decimal.new() |> Decimal.mult(cross_rate)

    %{total: total, cross_rate: cross_rate}
  end
end
