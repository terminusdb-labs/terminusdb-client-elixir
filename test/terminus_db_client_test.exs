defmodule TerminusDBClientTest do
  use ExUnit.Case
  doctest TerminusDBClient

  test "greets the world" do
    assert TerminusDBClient.hello() == :world
  end
end
