defmodule TerminusDBClient do
  @moduledoc """
  Documentation for `TerminusDBClient`.
  """

  defp create_request(client, method, route, params \\ %{}, body \\ nil) do
    headers =
      if client.token do
        [Authorization: "Bearer #{client.token}"]
      else
        []
      end

    headers =
      if body do
        [{"Content-Type", "application/json"} | headers]
      else
        headers
      end

    body =
      if body do
        Jason.encode!(body)
      else
        ""
      end

    %HTTPoison.Request{
      method: method,
      url: client.endpoint <> route,
      headers: headers,
      body: body,
      params: params
    }
  end

  defp from_object_stream(events) do
    reversed =
      Enum.reduce(events, [:start_array], fn event, acc ->
        case {hd(acc), event} do
          {:end_object, :start_object} -> [:start_object | [:comma | acc]]
          _ -> [event | acc]
        end
      end)

    :lists.reverse([:end_array | reversed])
  end

  defp decode_json_stream(string) do
    case Jaxon.Parser.parse(string) do
      {:ok, events} -> Jaxon.Decoders.Value.decode(from_object_stream(events))
      {:incomplete, _, string} -> {:error, "Incomplete JSON value: #{string}"}
      {:error, _} -> {:error, "JSON parsing error: #{string}"}
    end
  end

  defp handle_result({:ok, response}) do
    case response do
      %HTTPoison.Response{status_code: 200, body: body} -> {:ok, decode_json_stream(body)}
      _ -> {:error, response.status_code, decode_json_stream(response.body)}
    end

    {_, content_type} = List.keyfind(response.headers, "Content-Type", 0)

    message =
      if String.starts_with?(content_type, "application/json") do
        case decode_json_stream(response.body) do
          {:ok, decoded_body} -> decoded_body
          {:error, _} -> response.body
        end
      else
        response.body
      end

    result =
      if response.status_code >= 200 and response.status_code < 300 do
        :ok
      else
        :error
      end

    {result, message}
  end

  defp handle_result(result) do
    result
  end

  def ok(client) do
    create_request(client, :get, "/api/ok") |> HTTPoison.request() |> handle_result()
  end

  def create_db(client, db) do
    url = "/api/db/" <> client.team <> "/" <> db

    request =
      create_request(client, :post, url, %{}, %{
        comment: "Create a database",
        label: db
      })

    HTTPoison.request(request) |> handle_result()
  end

  def delete_db(client, db) do
    url = "/api/db/" <> client.team <> "/" <> db
    create_request(client, :delete, url) |> HTTPoison.request() |> handle_result()
  end

  def request_schema(client, db) do
    url = "/api/document/" <> client.team <> "/" <> db

    request =
      create_request(client, :get, url, %{
        graph_type: "schema"
      })

    HTTPoison.request(request) |> handle_result()
  end

  def create_schema(client, db, schema) do
    url = "/api/document/" <> client.team <> "/" <> db

    request =
      create_request(
        client,
        :post,
        url,
        %{
          graph_type: "schema",
          author: client.team,
          message: "Create a schema"
        },
        schema
      )

    HTTPoison.request(request) |> handle_result()
  end
end
