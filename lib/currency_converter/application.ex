defmodule CurrencyConverter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      CurrencyConverter.Repo,
      # Start the Telemetry supervisor
      CurrencyConverterWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: CurrencyConverter.PubSub},
      # Start the Endpoint (http/https)
      CurrencyConverterWeb.Endpoint,
      # Start Finch HTTP Client
      {Finch, name: Finch},
      # Start Oban
      {Oban, oban_config()},
      # Start Cachex
      {Cachex, name: :currency_converter}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CurrencyConverter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl Application
  def config_change(changed, _new, removed) do
    CurrencyConverterWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp oban_config do
    Application.fetch_env!(:currency_converter, Oban)
  end
end
