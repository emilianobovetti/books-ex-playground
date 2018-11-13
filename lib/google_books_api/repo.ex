defmodule GoogleBooksAPI.Repo do
  @moduledoc """
  Google books APIs repo.
  """

  @api_url "https://www.googleapis.com/books/v1/volumes"

  defp do_api_fetch!(url) when is_binary(url) do
    response = HTTPoison.get! url

    Map.put response, :json, Jason.decode!(response.body)
  end

  defp api_fetch!(%{id: id}) do
    do_api_fetch! "#{@api_url}/#{id}"
  end

  defp api_fetch!(%{isbn: isbn}) do
    api_fetch! %{query: "isbn:#{isbn}", max_results: 1}
  end

  defp api_fetch!(%{title: title} = params) do
    query = "intitle:#{title}"

    params
    |> Map.update(:query, query, &("#{&1} #{query}"))
    |> Map.delete(:title)
    |> api_fetch!()
  end

  defp api_fetch!(%{author: author} = params) do
    query = "inauthor:#{author}"

    params
    |> Map.update(:query, query, &("#{&1} #{query}"))
    |> Map.delete(:author)
    |> api_fetch!()
  end

  defp api_fetch!(%{publisher: publisher} = params) do
    query = "inpublisher:#{publisher}"

    params
    |> Map.update(:query, query, &("#{&1} #{query}"))
    |> Map.delete(:publisher)
    |> api_fetch!()
  end

  defp api_fetch!(%{subject: subject} = params) do
    query = "subject:#{subject}"

    params
    |> Map.update(:query, query, &("#{&1} #{query}"))
    |> Map.delete(:subject)
    |> api_fetch!()
  end

  defp api_fetch!(%{query: query} = params) do
    encoded_query =
      %{q: String.trim query}
      |> put_start_index(params)
      |> put_max_results(params)
      |> URI.encode_query()

    do_api_fetch! "#{@api_url}?#{encoded_query}"
  end

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

  defp parse_error(%{"error" => error = %{"message" => message}}) do
    {:error, Map.put(error, :message, message)}
  end

  defp parse_error(%{"totalItems" => 0}) do
    {:error, %{message: "Book not found."}}
  end

  defp parse_error(_json) do
    {:error, %{message: "Unknown error."}}
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

  def get_by(queryable, params) do
    case api_fetch! params do
      %{json: %{"items" => books}} when is_list(books) ->
        {:ok, Enum.map(books, &queryable.from_json/1)}

      %{status_code: 200, json: %{"totalItems" => 0}} ->
        {:ok, []}

      %{json: json} ->
        parse_error json
    end
  end
end
