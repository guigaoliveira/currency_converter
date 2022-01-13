import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :currency_converter, CurrencyConverter.Repo,
  username: "postgres",
  password: "postgres",
  database: "currency_converter_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :currency_converter, CurrencyConverterWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "RepvwiP5cidjE6ZHe7zFdvbfEdnJhbkbTryh42fwRGzZVJ4ybIB3duZiPPQURH1D",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :currency_converter, CurrencyConverter.HTTPClient, adapter: Tesla.Mock

config :currency_converter, CurrencyConverter.ExchangeRatesWorker, cache_persistence: false
