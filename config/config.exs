# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :currency_converter,
  ecto_repos: [CurrencyConverter.Repo],
  generators: [binary_id: true],
  supported_currencies: ["BRL", "USD", "EUR", "JPY"]

# Configures the endpoint
config :currency_converter, CurrencyConverterWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: CurrencyConverterWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: CurrencyConverter.PubSub,
  live_view: [signing_salt: "WGAmasJ0"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Oban Config
config :currency_converter, Oban,
  repo: CurrencyConverter.Repo,
  plugins: [
    Oban.Plugins.Pruner,
    {Oban.Plugins.Cron,
     crontab: [
       {"0 */12 * * *", CurrencyConverter.ExchangeRatesWorker}
     ]}
  ],
  queues: [exchange_rates: 10]

config :currency_converter, CurrencyConverter.ExchangeRatesWorker,
  # Free Plan does not support HTTPS
  base_url: "http://api.exchangeratesapi.io",
  url_path: "/v1/latest",
  access_key: System.get_env("EXCHANGE_RATES_API_ACCESS_KEY"),
  base_currency: "EUR",
  cache_persistence: true

config :currency_converter, CurrencyConverter.HTTPClient,
  adapter: {Tesla.Adapter.Finch, name: Finch}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
