# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :currency_converter,
  ecto_repos: [CurrencyConverter.Repo],
  generators: [binary_id: true]

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
  plugins: [Oban.Plugins.Pruner],
  queues: [exchange_rates: 10]

config :currency_converter, CurrencyConverter.ExchangeRatesWorker,
  # Free Plan does not support HTTPS
  base_url: "http://api.exchangeratesapi.io",
  access_key: "9b3187858df236e468834ce5575989a3"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
