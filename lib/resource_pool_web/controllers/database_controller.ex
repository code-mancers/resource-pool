defmodule ResourcePoolWeb.DatabaseController do
  use ResourcePoolWeb, :controller

  alias ResourcePool.Resources
  alias ResourcePool.Resources.Database

  action_fallback ResourcePoolWeb.FallbackController

  def index(conn, _params) do
    databases = Resources.list_databases()
    render(conn, "index.json", databases: databases)
  end

  def create(conn, %{"callback" => callback}) do
    Task.start fn ->
      Resources.create_resource_bulk(callback)
    end

    conn
    |> put_status(:ok)
    |> json(:ok)
  end

  def show(conn, %{"id" => id}) do
    database = Resources.get_database!(id)
    render(conn, "show.json", database: database)
  end

  def update(conn, %{"id" => id, "database" => database_params}) do
    database = Resources.get_database!(id)

    with {:ok, %Database{} = database} <- Resources.update_database(database, database_params) do
      render(conn, "show.json", database: database)
    end
  end

  def delete(conn, %{"id" => id}) do
    database = Resources.get_database!(id)
    with {:ok, %Database{}} <- Resources.delete_resource(database) do
      send_resp(conn, :no_content, "")
    end
  end
end
