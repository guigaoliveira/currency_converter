defmodule CurrencyConverter.Utils.EctoTypes.SortType do
  @moduledoc """
  An `Ecto.Type` that casts from a JSON string array and validates it.
  """

  use Ecto.Type

  @supported_directions ~w(asc desc)

  @impl true
  def type, do: :sort

  @impl true
  def cast(sort) when is_binary(sort) do
    with {:ok, [field, order]} when is_binary(field) and is_binary(order) <- Jason.decode(sort),
         true <- order in @supported_directions do
      {:ok, [String.downcase(field), order]}
    else
      _ -> :error
    end
  end

  def cast(_), do: :error

  @impl true
  def load(data), do: data

  @impl true
  def dump([field, order] = s) when is_binary(field) and is_binary(order), do: {:ok, s}
  def dump(_), do: :error
end
