defmodule CurrencyConverter.ExchangeRatesTest do
  use CurrencyConverter.DataCase

  alias CurrencyConverter.ExchangeRates

  doctest ExchangeRates

  setup do
    Cachex.clear(:currency_converter)

    create_exchange_rates()

    :ok
  end

  test "get/2" do
    assert {:ok, _value} = ExchangeRates.get("BRL")
    assert {:ok, _value} = ExchangeRates.get("BRL", persistence: true)

    assert {:ok, nil} = ExchangeRates.get("not_exist")
    assert {:ok, nil} = ExchangeRates.get("not_exist", persistence: true)

    Cachex.clear(:currency_converter)

    assert {:error, :unavailable_rates} = ExchangeRates.get("not_exist")
  end

  defp create_exchange_rates do
    exchange_rates = fixture(:exchange_rates)
    %{exchange_rates: exchange_rates}
  end

  defp fixture(:exchange_rates) do
    rates =
      Map.new(config_worker(:supported_currencies), fn currency ->
        {currency, to_string(:rand.uniform())}
      end)

    ExchangeRates.insert(rates, persistence: true)
    rates
  end

  defp config_worker(key) do
    :currency_converter
    |> Application.fetch_env!(CurrencyConverter.ExchangeRatesWorker)
    |> Keyword.fetch!(key)
  end
end
