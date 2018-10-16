defmodule ResourcePoolWeb.DatabaseView do
  use ResourcePoolWeb, :view
  alias ResourcePoolWeb.DatabaseView

  def render("index.json", %{databases: databases}) do
    %{data: render_many(databases, DatabaseView, "database.json")}
  end

  def render("show.json", %{database: database}) do
    %{data: render_one(database, DatabaseView, "database.json")}
  end

  def render("database.json", %{database: database}) do
    %{
      external_id: database.id,
      value: "#{database.host}:#{database.port}"
    }
  end
end
