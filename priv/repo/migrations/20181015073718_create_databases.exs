defmodule ResourcePool.Repo.Migrations.CreateDatabases do
  use Ecto.Migration

  def change do
    create table(:databases) do
      add :name, :string
      add :port, :integer
      add :host, :string
      add :db_path, :string
      add :log_path, :string

      timestamps()
    end

  end
end
