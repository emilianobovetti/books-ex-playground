defmodule BooksWeb.Router do
  use BooksWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BooksWeb do
    pipe_through :browser # Use the default browser stack

    get "/get/:id", RestController, :get_by_id
  end

  # Other scopes may use custom stacks.
  # scope "/api", BooksWeb do
  #   pipe_through :api
  # end
  forward "/api", Absinthe.Plug,
    schema: GraphQL.Book.Schema

  forward "/graphiql", Absinthe.Plug.GraphiQL,
    schema: GraphQL.Book.Schema,
    interface: :playground # :advanced :simple :playground
end
