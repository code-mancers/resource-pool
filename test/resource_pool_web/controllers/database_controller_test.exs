defmodule ResourcePoolWeb.DatabaseControllerTest do
  use ResourcePoolWeb.ConnCase

  alias ResourcePool.Resources
  alias ResourcePool.Resources.Database

  @create_attrs %{db_path: "some db_path", host: "some host", log_path: "some log_path", name: "some name", port: 42}
  @update_attrs %{db_path: "some updated db_path", host: "some updated host", log_path: "some updated log_path", name: "some updated name", port: 43}
  @invalid_attrs %{db_path: nil, host: nil, log_path: nil, name: nil, port: nil}

  def fixture(:database) do
    {:ok, database} = Resources.create_database(@create_attrs)
    database
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all databases", %{conn: conn} do
      conn = get conn, database_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create database" do
    test "renders database when data is valid", %{conn: conn} do
      conn = post conn, database_path(conn, :create), database: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, database_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "db_path" => "some db_path",
        "host" => "some host",
        "log_path" => "some log_path",
        "name" => "some name",
        "port" => 42}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, database_path(conn, :create), database: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update database" do
    setup [:create_database]

    test "renders database when data is valid", %{conn: conn, database: %Database{id: id} = database} do
      conn = put conn, database_path(conn, :update, database), database: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, database_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "db_path" => "some updated db_path",
        "host" => "some updated host",
        "log_path" => "some updated log_path",
        "name" => "some updated name",
        "port" => 43}
    end

    test "renders errors when data is invalid", %{conn: conn, database: database} do
      conn = put conn, database_path(conn, :update, database), database: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete database" do
    setup [:create_database]

    test "deletes chosen database", %{conn: conn, database: database} do
      conn = delete conn, database_path(conn, :delete, database)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, database_path(conn, :show, database)
      end
    end
  end

  defp create_database(_) do
    database = fixture(:database)
    {:ok, database: database}
  end
end
