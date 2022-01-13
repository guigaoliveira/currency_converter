defmodule CurrencyConverterWeb.ChangesetView do
  use CurrencyConverterWeb, :view

  @doc """
  Traverses and translates changeset errors.
  See `Ecto.Changeset.traverse_errors/2` and
  `TuiterWeb.ErrorHelpers.translate_error/1` for more details.
  """
  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  def render("validation_errors.json", %{changeset: changeset, status: status}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{errors: [%{detail: translate_errors(changeset), status: status}]}
  end
end
