defmodule CurrencyConverterWeb.Router do
  use CurrencyConverterWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CurrencyConverterWeb do
    pipe_through :api

    get "/", TransactionController, :index
  end
end
