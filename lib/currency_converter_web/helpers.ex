defmodule CurrencyConverterWeb.Helpers do
  @moduledoc """
  Helpers for Controllers and Views
  """

  import Plug.Conn, only: [put_status: 2, halt: 1]
  import Phoenix.Controller, only: [put_view: 2, render: 3]
  alias Plug.Conn.Status

  def create_error_view(conn, status, detail) do
    status_code = Status.code(status)

    conn
    |> put_status(status)
    |> put_view(CurrencyConverterWeb.ErrorView)
    |> render(:"#{status_code}", detail: detail, status: status_code)
    |> halt()
  end
end
