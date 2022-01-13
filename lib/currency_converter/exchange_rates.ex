defmodule CurrencyConverter.ExchangeRates do
  @moduledoc """
  Exchange Rates Context
  """

  require Logger

  @persistence_path "/tmp/exchange_rates_backup"

  @doc """
  Insert exchange rates into global cache
  """
  @spec insert(map, Keyword.t()) :: {:ok, boolean} | {:error, boolean}
  def insert(rates, opts \\ []) do
    Cachex.put(:currency_converter, "exchange_rates", rates)

    if opts[:persistence] do
      Cachex.dump(:currency_converter, @persistence_path)
    end
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
