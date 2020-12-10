defmodule Memex.Search.QueryTest do
  use ExUnit.Case, async: true

  alias Memex.Search.Query

  test "add filters" do
    query = Query.add_filter(%Query{}, "date", "2020")
    assert query.filters == %{"date" => "2020"}
  end

  test "serialize to string" do
    query =
      %Query{}
      |> Query.add_filter("date", "2020")
      |> Query.to_string()

    assert query == "date:2020"
  end

  test "from string" do
    query = Query.from_string("test date:2020")

    assert query.query == "test"
    assert query.filters == %{"date" => "2020"}
  end

  test "from string broken" do
    query = Query.from_string("test date:")

    assert query.query == "test date:"
    assert query.filters == %{}
  end
end
