defmodule GoogleBooksAPI.Repo do
  @moduledoc """
  Google books APIs repo.
  """

  @api_url "https://www.googleapis.com/books/v1/volumes"

  def get(queryable, id, opts \\ %{}) do
    %{status_code: status, body: body} = HTTPoison.get! "#{@api_url}/#{id}"
    response_json = Poison.decode! body

    case status do
      200 ->
        {:ok, queryable.from_json response_json}

      _ ->
        {:error, get_in(response_json, ["error", "message"])}
    end
  end
end
