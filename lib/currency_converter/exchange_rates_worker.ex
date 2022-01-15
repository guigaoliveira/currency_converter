defmodule CurrencyConverter.ExchangeRatesWorker do
  @moduledoc """
  This module is responsible for extracting exchange rates from an external API
  and adding it to a global cache.
  """
  use Oban.Worker,
    queue: :exchange_rates,
    max_attempts: 1

  alias CurrencyConverter.ExchangeRates
  alias CurrencyConverter.HTTPClient

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{attempt: attempt}) do
    url = config_worker(:base_url)
    client = HTTPClient.new(url: url)

    Logger.info(
      "Trying to extract exchange rates from #{inspect(url)}, attempt: #{inspect(attempt)}..."
    )

    with {:ok, %{body: body}} <-
           HTTPClient.request(client,
             url: config_worker(:url_path),
             method: :get,
             query: [
               access_key: config_worker(:access_key),
               base: config_worker(:base_currency)
             ]
           ),
         {:ok, rates} <- parse_result(body) do
      ExchangeRates.insert(rates, persistence: config_worker(:cache_persistence))
      :ok
    else
      error ->
        Logger.error(
          "New error when try to extract exchange rates, details: #{inspect(error)}..."
        )

        error
    end
  end

  defp parse_result(%{"rates" => rates}) do
    {:ok,
     rates
     |> Map.take(config_global(:supported_currencies))
     |> Map.new(fn {k, v} -> {k, to_string(v)} end)}
  end

  defp parse_result(_body), do: {:error, :exchange_api_schema_changed}

  defp config_worker(key),
    do: :currency_converter |> Application.fetch_env!(__MODULE__) |> Keyword.fetch!(key)

  defp config_global(key), do: Application.fetch_env!(:currency_converter, key)
end
