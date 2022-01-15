defmodule CurrencyConverter.Utils.Validations.SortValidation do
  @moduledoc """
  Sort is a list of strings of fields and order to sort.
  """

  import Ecto.Changeset

  @default_sort desc: :inserted_at

  @spec apply(Ecto.Changeset.t(), [String.t()], Keyword.t()) :: Ecto.Changeset.t()
  def apply(changeset, sort_fields, default_sort \\ @default_sort) do
    case get_change(changeset, :sort) do
      nil -> put_change(changeset, :sort, default_sort)
      [field, order] -> validate_field(changeset, field, order, sort_fields)
    end
  end

  defp validate_field(changeset, field, order, sort_fields) do
    if field in sort_fields do
      put_change(changeset, :sort, [
        {String.to_existing_atom(order), String.to_existing_atom(field)}
      ])
    else
      add_error(changeset, :sort, "Invalid sort field '#{field}'")
    end
  end
end
