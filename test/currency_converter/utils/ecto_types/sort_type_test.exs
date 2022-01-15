defmodule CurrencyConverter.Utils.EctoTypes.SortTypeTest do
  use CurrencyConverter.DataCase

  alias CurrencyConverter.Utils.EctoTypes.SortType
  doctest SortType

  test "type/0" do
    assert SortType.type() == :sort
  end

  test "cast/1" do
    assert SortType.cast(~S(["inserted_at","desc"])) == {:ok, ["inserted_at", "desc"]}

    assert SortType.cast(:not_a_binary) == :error
  end

  test "load/1" do
    assert SortType.load("data") == {:ok, "data"}
  end

  test "dump/1" do
    assert SortType.dump(["inserted_at", "desc"]) == {:ok, ["inserted_at", "desc"]}
    assert SortType.dump(:not_a_list) == :error
  end
end
