defmodule GraphQL.Book.Schema do
  use Absinthe.Schema

  def resolver(params, _) do
    GoogleBooksAPI.Repo.get_by Book, params
  end

  query do
    field :book_by_id, :book do
      arg :id, type: non_null(:id)

      resolve &resolver/2
    end

    field :book_by_isbn, :book do
      arg :isbn, type: non_null(:string)

      resolve &resolver/2
    end

    field :books, list_of(:book) do
      arg :query, type: :string

      arg :title, type: :string
      arg :author, type: :string
      arg :publisher, type: :string
      arg :subject, type: :string

      arg :max_results, type: :integer
      arg :start_index, type: :integer

      resolve &resolver/2
    end
  end

  object :book do
    field :id, :id
    field :title, :string
    field :description, :string
    field :authors, list_of(:string)
    field :page_count, :integer
    field :average_rating, :float
    field :is_ebook, :boolean
  end
end
