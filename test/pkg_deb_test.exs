defmodule PkgDebTest do
  use ExUnit.Case
  doctest PkgDeb

  test "greets the world" do
    assert PkgDeb.hello() == :world
  end
end
