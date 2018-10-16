defmodule ResourcePool.Resources do
  @moduledoc """
  The Resources context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias ResourcePool.Repo

  alias ResourcePool.Resources.Database

  def create_resource_bulk(nOfResource \\ 5) do
    1..nOfResource
    |> Enum.map(fn _ -> create_resource() end)
    |> Enum.reject(&match?({:error, _}, &1))
    |> Enum.map(fn {:ok, database} -> database end)
  end

  def create_resource() do
    with {:ok, %{record_db: database}} <- do_create_resource() do
      {:ok, database}
    else
      _ -> {:error, "unable to create resource"}
    end
  end

  defp do_create_resource() do
    Multi.new
    |> prepare_params()
    |> create_postgres_db()
    |> record_db()
    |> Repo.transaction()
  end

  def delete_resource(db) do
    with {:ok, %{delete_db: database}} <- do_delete_resource(db) do
      {:ok, database}
    else
      _ -> {:error, "unable to create resource"}
    end
  end

  def do_delete_resource(db) do
    Multi.new
    |> delete_postgres_db(db)
    |> delete_db(db)
    |> Repo.transaction()
  end

  defp prepare_params(multi) do
    db_path = get_db_path()
    Multi.run(multi, :prepare_params, fn _ ->
      {:ok,
        %{
          db_path: db_path,
          log_path: get_log_path(db_path),
          name: get_db_name(db_path),
          port: get_port(),
          host: get_host()
        }
      }
    end)
  end

  defp create_postgres_db(multi) do
    Multi.run(multi, :create_postgress_db, fn %{prepare_params: params} ->
      opts = "-h #{params[:host]} -p #{params[:port]}"
      IO.inspect ["-D", params[:db_path], "-o", opts, "-l", params[:log_path], "start"]

      with {_, 0} <- System.cmd("initdb", ["-D", params[:db_path]]),
           {_, 0} <- System.cmd("pg_ctl", ["-D", params[:db_path],
             "-o", opts, "-l", params[:log_path], "start"]) do
        {:ok, params}
      else
        {:error, error} ->
          IO.puts "some weird error, #{inspect error}"
          {:error, "Couldn't create the database"}
      end
    end)
  end

  def record_db(multi) do
    Multi.run(multi, :record_db, fn %{prepare_params: params} ->
      create_database(params)
    end)
  end

  defp get_db_path() do
    Application.get_env(:resource_pool, :base_path)
    |> Path.join(gen_random_db_name())
  end

  defp get_db_name(db_path) do
    db_path
    |> Path.split()
    |> List.last()
  end

  defp get_log_path(db_path) do
    db_path
    |> Path.join("db.log")
  end

  defp get_port() do
    gen_random_unused_port()
  end

  defp get_host() do
    # extract ip
    {:ok, [{inet, _, _} | _]} = :inet.getif()

    inet
    |> Tuple.to_list()
    |> Enum.join(".")
  end

  defp gen_random_db_name() do
    ?a..?z
    |> Enum.take_random(10)
    |> to_string()
  end

  defp gen_random_unused_port() do
    5000..50000
    |> Enum.take_random(1)
    |> Enum.at(0)
  end

  defp delete_postgres_db(multi, db) do
    Multi.run(multi, :delete_postgres_db, fn _ ->
      opts = "-h #{db.host} -p #{db.port}"
      with {_, 0} <- System.cmd("pg_ctl", ["-D", db.db_path, "-o", opts, "-l", db.log_path, "stop"]),
          {:ok, _} <- File.rm_rf(db.db_path) do
        {:ok, db}
      else
        _ -> {:error, "Couldn't delete the database"}
      end
    end)
  end

  def delete_db(multi, db) do
    Multi.delete(multi, :delete_db, db)
  end

  @doc """
  Returns the list of databases.

  ## Examples

      iex> list_databases()
      [%Database{}, ...]

  """
  def list_databases do
    Repo.all(Database)
  end

  @doc """
  Gets a single database.

  Raises `Ecto.NoResultsError` if the Database does not exist.

  ## Examples

      iex> get_database!(123)
      %Database{}

      iex> get_database!(456)
      ** (Ecto.NoResultsError)

  """
  def get_database!(id), do: Repo.get!(Database, id)

  @doc """
  Creates a database.

  ## Examples

      iex> create_database(%{field: value})
      {:ok, %Database{}}

      iex> create_database(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_database(attrs \\ %{}) do
    %Database{}
    |> Database.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a database.

  ## Examples

      iex> update_database(database, %{field: new_value})
      {:ok, %Database{}}

      iex> update_database(database, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_database(%Database{} = database, attrs) do
    database
    |> Database.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Database.

  ## Examples

      iex> delete_database(database)
      {:ok, %Database{}}

      iex> delete_database(database)
      {:error, %Ecto.Changeset{}}

  """
  def delete_database(%Database{} = database) do
    Repo.delete(database)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking database changes.

  ## Examples

      iex> change_database(database)
      %Ecto.Changeset{source: %Database{}}

  """
  def change_database(%Database{} = database) do
    Database.changeset(database, %{})
  end
end
