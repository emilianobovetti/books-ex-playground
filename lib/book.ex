defmodule Book do
  @moduledoc """
  TODO
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Poison.Encoder, except: [:__meta__]}

  schema "book" do
    field :title, :string
    field :description, :string
    field :authors, {:array, :string}
    field :page_count, :integer
    field :average_rating, :float
    field :is_ebook, :boolean
  end

  def from_json(data) do
    volume_info = data["volumeInfo"]

    %__MODULE__{
      id: data["id"],
      title: volume_info["title"],
      description: volume_info["description"],
      authors: volume_info["authors"],
      page_count: volume_info["pageCount"],
      average_rating: volume_info["averageRating"],
      is_ebook: volume_info["isEbook"]
    }
  end
end
