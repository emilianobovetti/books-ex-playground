defmodule GraphQL.Book.Schema do
  use Absinthe.Schema

  query do
    @desc "Get a book from GoogleAPIs"
    field :google_book, :book do

      @desc "The book ID"
      arg :id, type: non_null(:id)

      resolve fn %{id: id}, _ ->
        GoogleBooksAPI.Repo.get Book, id
      end
    end
  end

  object :book do
    field :id, :id
    field :title, :string
    field :description, :string
    field :page_count, :integer
    field :average_rating, :float
    field :is_ebook, :boolean
  end
end
