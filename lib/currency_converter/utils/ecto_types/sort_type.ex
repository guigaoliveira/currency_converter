defmodule CurrencyConverter.Utils.EctoTypes.SortType do
  @moduledoc """
  An `Ecto.Type` that casts from a JSON string array and validates it.
  """

  use Ecto.Type

  @supported_directions ~w(asc desc)

  @impl Ecto.Type
  @spec type :: :sort
  def type, do: :sort

  @impl Ecto.Type
  @spec cast(any) :: :error | {:ok, [binary, ...]}
  def cast(sort) when is_binary(sort) do
    with {:ok, [field, order]} when is_binary(field) and is_binary(order) <- Jason.decode(sort),
         true <- order in @supported_directions do
      {:ok, [String.downcase(field), order]}
    else
      _ -> :error
    end
  end

  def cast(_), do: :error

  @impl Ecto.Type
  @spec load(any) :: {:ok, any}
  def load(data), do: {:ok, data}

  @impl Ecto.Type
  @spec dump(any) :: :error | {:ok, [binary, ...]}
  def dump([field, order] = s) when is_binary(field) and is_binary(order), do: {:ok, s}
  def dump(_), do: :error
end
