defmodule TerminusDBClientTest do
  use ExUnit.Case
  doctest TerminusDBClient

  @client %TerminusDBClient.WOQLClient{
    endpoint: "http://admin:root@localhost:6363",
    team: "admin"
  }

  test "ok" do
    {:ok, ""} = TerminusDBClient.ok(@client)
  end

  test "create and delete a database" do
    {:ok, _} = TerminusDBClient.create_db(@client, "t")
    {:ok, _} = TerminusDBClient.delete_db(@client, "t")
  end
end
