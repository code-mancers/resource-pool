defmodule ResourcePool.Resources.Database do
  use Ecto.Schema
  import Ecto.Changeset


  schema "databases" do
    field :db_path, :string
    field :host, :string
    field :log_path, :string
    field :name, :string
    field :port, :integer

    timestamps()
  end

  @doc false
  def changeset(database, attrs) do
    database
    |> cast(attrs, [:name, :port, :host, :db_path, :log_path])
    |> validate_required([:name, :port, :host, :db_path, :log_path])
  end
end
