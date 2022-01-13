defmodule CurrencyConverterWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.
  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use CurrencyConverterWeb, :controller

  alias CurrencyConverterWeb.Helpers

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    render_validation_errors(conn, changeset)
  end

  def call(conn, %Ecto.Changeset{valid?: false} = changeset) do
    render_validation_errors(conn, changeset)
  end

  def call(conn, {:error, status, detail}) do
    Helpers.create_error_view(conn, status, detail)
  end

  defp render_validation_errors(conn, changeset) do
    status = 422

    conn
    |> put_status(status)
    |> put_view(CurrencyConverterWeb.ChangesetView)
    |> render("validation_errors.json", changeset: changeset, status: status)
  end
end
