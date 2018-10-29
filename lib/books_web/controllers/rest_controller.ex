defmodule BooksWeb.RestController do
  use BooksWeb, :controller

  def get_by_id(conn, params) do
    case GoogleBooksAPI.Repo.get Book, params["id"] do
      {:ok, book} ->
        json conn, book

      {:error, error} ->
        json conn, error
    end
  end
end
