defmodule CurrencyConverter.ExchangeRatesWorkerTest do
  use CurrencyConverter.DataCase

  alias CurrencyConverter.{ExchangeRates, ExchangeRatesWorker}

  @moduletag :capture_log

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

      %{
        url: ^url,
        method: :get,
        query: [
          access_key: _,
          base: ^base_currency
        ]
      } ->
        %Tesla.Env{
          status: 401,
          body: %{
            "error" => %{
              "code" => "missing_access_key",
              "message" =>
                "You have not supplied an API Access Key. [Required format: access_key=YOUR_ACCESS_KEY]"
            }
          }
        }
    end)

    :ok
  end

  test "should extract exchange rates and save in cache" do
    assert :ok = perform_job(ExchangeRatesWorker, %{}, attempt: 1)
    assert ExchangeRates.get("BRL") > 0
  end

  test "should return a error when" do
    envs = Application.fetch_env!(:currency_converter, ExchangeRatesWorker)

    Application.put_env(
      :currency_converter,
      ExchangeRatesWorker,
      Keyword.merge(envs, access_key: :access_key_not_exist)
    )

    assert {:error, :unavailable} = perform_job(ExchangeRatesWorker, %{}, attempt: 1)
  end

  defp config_worker(key) do
    Application.fetch_env!(:currency_converter, ExchangeRatesWorker) |> Keyword.fetch!(key)
  end
end
