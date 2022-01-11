defmodule CurrencyConverter.ExchangeRatesWorker do
  use Oban.Worker, queue: :exchange_rates

  alias CurrencyConverter.HTTPClient

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    client = HTTPClient.new(url: config(:base_url))

    case HTTPClient.request(client,
           url: "/v1/latest",
           method: :get,
           query: [
             access_key: config(:access_key),
             base: "EUR"
           ]
         ) do
      {:ok, %{body: body}} ->
        IO.inspect(body)
        :ok

      {:error, error} ->
        {:error, error}
    end
  end

  defp config(key) do
    Application.fetch_env!(:currency_converter, __MODULE__) |> Keyword.fetch!(key)
  end
end
