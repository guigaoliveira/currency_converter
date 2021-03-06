defmodule CurrencyConverter.ExchangeRates do
  @moduledoc """
  Exchange Rates Context
  """

  require Logger

  # can become environment variables
  @persistence_path "/tmp/exchange_rates_backup"
  @default_ttl :timer.hours(24)

  @doc """
  Insert exchange rates into global cache
  """
  @spec insert(map, Keyword.t()) :: {:ok, boolean} | {:error, boolean}
  def insert(rates, opts \\ []) do
    if opts[:persistence] do
      Cachex.dump(:currency_converter, @persistence_path)
    end

    Cachex.put(:currency_converter, "exchange_rates", rates, ttl: opts[:ttl] || @default_ttl)
  end

  @doc """
  Get exchange rates from global cache
  """
  @spec get(String.t(), Keyword.t()) :: {:error, :not_found_rates} | {:ok, any}
  def get(currency, opts \\ []) do
    if opts[:persistence] do
      Cachex.load(:currency_converter, @persistence_path)
    end

    case Cachex.get!(:currency_converter, "exchange_rates") do
      nil ->
        {:error, :unavailable_rates}

      value ->
        {:ok, Map.get(value, currency)}
    end
  rescue
    error ->
      Logger.debug(
        "New error when try to get exchange rates from cache, reason: #{inspect(error)}"
      )

      {:error, :unavailable_rates}
  end
end
