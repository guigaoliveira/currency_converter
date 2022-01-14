defmodule CurrencyConverter.HTTPClient do
  @moduledoc """
  HTTP Client
  """

  require Logger

  @typedoc """
  Possible error reasons.
  """
  @type error_reason ::
          :unavailable
          | :unexpected_return

  @typedoc """
  Possible bodies in an HTTP response.
  """
  @type body ::
          %{required(String.t()) => body() | nil}
          | list(body())
          | number()
          | boolean()
          | String.t()

  @typedoc """
  Success response.
  """
  @type success_response() :: %{
          body: body,
          headers: [{binary, binary}],
          status: integer | nil
        }

  @typedoc """
  All types of HTTP call returns.
  """
  @type http_return ::
          {:ok, success_response()}
          | {:error, {error_reason(), body()} | :unexpected_return | error_reason()}

  defguardp is_success(status) when is_integer(status) and status >= 200 and status < 300

  @spec new(Keyword.t()) :: Tesla.Client.t()
  def new(opts \\ []) do
    middlewares = [
      {Tesla.Middleware.BaseUrl, opts[:url] || ""},
      {Tesla.Middleware.Compression, format: opts[:compression] || "gzip"},
      {Tesla.Middleware.Retry,
       should_retry: fn
         {:ok, %{status: status}} when status in 500..599 -> true
         {:ok, _} -> false
         {:error, _} -> true
       end},
      Tesla.Middleware.JSON,
      Tesla.Middleware.KeepRequest,
      Tesla.Middleware.Telemetry,
      Tesla.Middleware.Logger
    ]

    adapter = config(:adapter)
    Tesla.client(middlewares, adapter)
  end

  @spec request(Tesla.Client.t(), [{:body | :headers | :method | :opts | :query | :url, any}]) ::
          http_return()
  def request(client, request_opts) do
    client
    |> Tesla.request(request_opts)
    |> parse_result()
  end

  defp parse_result({:ok, %{status: status} = env}) when is_success(status) do
    {:ok, %{body: env.body, headers: env.headers, status: status}}
  end

  defp parse_result({:ok, %{status: status, body: body}}) do
    Logger.warning("#{__MODULE__}: New error when #{status}, body: #{inspect(body)}")
    {:error, :unavailable}
  end

  defp parse_result({:error, _reason} = err), do: err

  defp config(key) do
    Application.fetch_env!(:currency_converter, __MODULE__) |> Keyword.fetch!(key)
  end
end
