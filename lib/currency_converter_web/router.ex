defmodule CurrencyConverterWeb.Router do
  use CurrencyConverterWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CurrencyConverterWeb do
    pipe_through :api

    get "/conversion_transactions/:user_id", ConversionTransactionController, :index
  end
end
