defmodule GoogleBooksAPI.Repo do
  @moduledoc """
  Google books APIs repo.
  """

  @api_url "https://www.googleapis.com/books/v1/volumes"

  defp put_start_index(query_map, %{start_index: start_index}) do
    Map.put query_map, "startIndex", start_index
  end

  defp put_start_index(query_map, _) do
    query_map
  end

  defp put_max_results(query_map, %{max_results: max_results}) when max_results > 40 do
    put_max_results query_map, %{max_results: 40}
  end

  defp put_max_results(query_map, %{max_results: max_results}) do
    Map.put query_map, "maxResults", max_results
  end

  defp put_max_results(query_map, _) do
    query_map
  end

  defp do_api_fetch!(url) when is_binary(url) do
    response = HTTPoison.get! url

    Map.put response, :json, Poison.decode!(response.body)
  end

  defp api_fetch!(%{id: id}) do
    do_api_fetch! "#{@api_url}/#{id}"
  end

  defp api_fetch!(%{query: query} = query_params) do
    encoded_query =
      %{q: query}
      |> put_start_index(query_params)
      |> put_max_results(query_params)
      |> URI.encode_query

    do_api_fetch! "#{@api_url}?#{encoded_query}"
  end

  defp api_fetch!(%{isbn: isbn}) do
    api_fetch! %{query: "isbn:#{isbn}", max_results: 1}
  end

  defp parse_error(json) do
    {:error, get_in(json, ["error", "message"])}
  end

  def get(queryable, id) do
    get_by queryable, %{id: id}
  end

  def get_by(queryable, %{id: id} = params) do
    case api_fetch! params do
      %{status_code: 200, json: json} ->
        {:ok, queryable.from_json json}

      %{json: json} ->
        parse_error json
    end
  end

  def get_by(queryable, %{isbn: isbn} = params) do
    case api_fetch! params do
      %{json: %{"items" => [json | _]}} ->
        {:ok, queryable.from_json json}

      %{json: json} ->
        parse_error json
    end
  end

  def get_by(queryable, %{query: query} = params) do
    case api_fetch! params do
      %{status_code: 200, json: json} ->
        {:ok, Enum.map(json["items"], &queryable.from_json/1)}

      %{json: json} ->
        parse_error json
    end
  end
end
