defmodule CurrencyConverter.ExchangeRatesWorker do
  use Oban.Worker,
    queue: :exchange_rates,
    max_attempts: 10

  alias CurrencyConverter.{ExchangeRates, HTTPClient}

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{attempt: attempt}) do
    url = config(:base_url)
    client = HTTPClient.new(url: url)

    Logger.info("Trying to extract exchange rates from #{url}, attempt: #{attempt}...")

    with {:ok, %{body: body}} <-
           HTTPClient.request(client,
             url: config(:url_path),
             method: :get,
             query: [
               access_key: config(:access_key),
               base: config(:base_currency)
             ]
           ),
         {:ok, rates} <- parse_result(body) do
      ExchangeRates.insert(rates, persistence: config(:cache_persistence))
      :ok
    else
      error ->
        Logger.error("New error when try to extract exchange rates, details: #{error}...")
        error
    end
  end

  defp parse_result(%{"rates" => rates}) do
    {:ok,
     rates
     |> Map.take(config(:supported_currencies))
     |> Map.new(fn {k, v} -> {k, to_string(v)} end)}
  end

  defp parse_result(_body), do: {:error, :exchange_api_schema_changed}

  defp config(key) do
    Application.fetch_env!(:currency_converter, __MODULE__) |> Keyword.fetch!(key)
  end
end
