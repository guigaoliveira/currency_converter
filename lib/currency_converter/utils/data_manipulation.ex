defmodule CurrencyConverter.Utils.DataManipulation do
  @moduledoc """
  Module responsible for concentrating data manipulation with Ecto Query
  """

  import Ecto.Query, warn: false

  @doc """
  Apply data operations (pagination, filters and sorting) to query
  """
  @spec apply_operations(Ecto.Query.t(), map) :: Ecto.Query.t()
  def apply_operations(query, operations) do
    Enum.reduce(operations, query, fn {operation, value}, query ->
      apply_operations(query, to_atom(operation), value)
    end)
  end

  defp to_atom(value) when is_binary(value), do: String.to_existing_atom(value)
  defp to_atom(value), do: value

  defp apply_operations(query, _, nil), do: query

  defp apply_operations(query, :inserted_at, datetime),
    do: where(query, [j], j.inserted_at >= ^datetime)

  defp apply_operations(query, :inserted_at_start, inserted_at_start),
    do: where(query, [u], u.inserted_at >= ^inserted_at_start)

  defp apply_operations(query, :inserted_at_end, inserted_at_end),
    do: where(query, [u], u.inserted_at <= ^inserted_at_end)

  # we can improve this to cursor based pagination (for example)
  defp apply_operations(query, :offset, offset), do: offset(query, ^offset)
  defp apply_operations(query, :limit, limit), do: limit(query, ^limit)

  defp apply_operations(query, :sort, sort) when is_map(sort),
    do: apply_operations(query, :sort, Map.to_list(sort))

  defp apply_operations(query, :sort, sort), do: order_by(query, ^sort)

  defp apply_operations(query, _, _), do: query
end
