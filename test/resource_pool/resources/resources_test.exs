defmodule ResourcePool.ResourcesTest do
  use ResourcePool.DataCase

  alias ResourcePool.Resources

  describe "databases" do
    alias ResourcePool.Resources.Database

    @valid_attrs %{db_path: "some db_path", host: "some host", log_path: "some log_path", name: "some name", port: 42}
    @update_attrs %{db_path: "some updated db_path", host: "some updated host", log_path: "some updated log_path", name: "some updated name", port: 43}
    @invalid_attrs %{db_path: nil, host: nil, log_path: nil, name: nil, port: nil}

    def database_fixture(attrs \\ %{}) do
      {:ok, database} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Resources.create_database()

      database
    end

    test "list_databases/0 returns all databases" do
      database = database_fixture()
      assert Resources.list_databases() == [database]
    end

    test "get_database!/1 returns the database with given id" do
      database = database_fixture()
      assert Resources.get_database!(database.id) == database
    end

    test "create_database/1 with valid data creates a database" do
      assert {:ok, %Database{} = database} = Resources.create_database(@valid_attrs)
      assert database.db_path == "some db_path"
      assert database.host == "some host"
      assert database.log_path == "some log_path"
      assert database.name == "some name"
      assert database.port == 42
    end

    test "create_database/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Resources.create_database(@invalid_attrs)
    end

    test "update_database/2 with valid data updates the database" do
      database = database_fixture()
      assert {:ok, database} = Resources.update_database(database, @update_attrs)
      assert %Database{} = database
      assert database.db_path == "some updated db_path"
      assert database.host == "some updated host"
      assert database.log_path == "some updated log_path"
      assert database.name == "some updated name"
      assert database.port == 43
    end

    test "update_database/2 with invalid data returns error changeset" do
      database = database_fixture()
      assert {:error, %Ecto.Changeset{}} = Resources.update_database(database, @invalid_attrs)
      assert database == Resources.get_database!(database.id)
    end

    test "delete_database/1 deletes the database" do
      database = database_fixture()
      assert {:ok, %Database{}} = Resources.delete_database(database)
      assert_raise Ecto.NoResultsError, fn -> Resources.get_database!(database.id) end
    end

    test "change_database/1 returns a database changeset" do
      database = database_fixture()
      assert %Ecto.Changeset{} = Resources.change_database(database)
    end
  end
end
