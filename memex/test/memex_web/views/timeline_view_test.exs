defmodule MemexWeb.TimelineViewTest do
  use MemexWeb.ConnCase, async: true

  test "Return a short format of a number" do
    assert MemexWeb.TimelineView.number_short(12) == 12
    assert MemexWeb.TimelineView.number_short(1234) == "1.2K"
    assert MemexWeb.TimelineView.number_short(12_345) == "12.3K"
    assert MemexWeb.TimelineView.number_short(123_456) == "123.5K"
    assert MemexWeb.TimelineView.number_short(1_234_567) == "1.2M"
    assert MemexWeb.TimelineView.number_short(12_345_678) == "12.3M"
  end
end
