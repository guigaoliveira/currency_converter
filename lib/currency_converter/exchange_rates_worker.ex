defmodule CurrencyConverter.ExchangeRatesWorker do
  use Oban.Worker, queue: :exchange_rates

  alias CurrencyConverter.{ExchangeRates, HTTPClient}

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    client = HTTPClient.new(url: config(:base_url))

    with {:ok, %{body: body}} <-
           HTTPClient.request(client,
             url: "/v1/latest",
             method: :get,
             query: [
               access_key: config(:access_key),
               base: config(:base_currency)
             ]
           ),
         {:ok, rates} <- parse_result(body) do
      ExchangeRates.insert(rates, persistence: true)
      :ok
    end
  end

  defp parse_result(%{"rates" => rates}),
    do: {:ok, Map.take(rates, config(:supported_currencies))}

  defp parse_result(_body), do: {:error, :exchange_api_schema_changed}

  defp config(key) do
    Application.fetch_env!(:currency_converter, __MODULE__) |> Keyword.fetch!(key)
  end
end
