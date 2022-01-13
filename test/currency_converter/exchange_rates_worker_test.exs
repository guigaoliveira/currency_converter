defmodule CurrencyConverter.ExchangeRatesWorkerTest do
  use CurrencyConverter.DataCase

  alias CurrencyConverter.{ExchangeRates, ExchangeRatesWorker}

  setup do
    url = config_worker(:base_url) <> config_worker(:url_path)
    access_key = config_worker(:access_key)
    base_currency = config_worker(:base_currency)

    rates =
      Map.new(config_worker(:supported_currencies), fn currency ->
        {currency, to_string(:rand.uniform())}
      end)

    Tesla.Mock.mock(fn
      %{
        url: ^url,
        method: :get,
        query: [
          access_key: ^access_key,
          base: ^base_currency
        ]
      } ->
        %Tesla.Env{
          status: 200,
          body: %{
            "base" => base_currency,
            "date" => Date.to_string(Date.utc_today()),
            "rates" => rates,
            "success" => true,
            "timestamp" => DateTime.to_unix(DateTime.utc_now(), :millisecond)
          }
        }
    end)

    :ok
  end

  test "should exctract exchange rates and save in cache" do
    assert :ok = perform_job(ExchangeRatesWorker, %{}, attempt: 1)
    assert ExchangeRates.get("BRL") > 0
  end

  defp config_worker(key) do
    Application.fetch_env!(:currency_converter, ExchangeRatesWorker) |> Keyword.fetch!(key)
  end
end
