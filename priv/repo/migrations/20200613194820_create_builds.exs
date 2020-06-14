defmodule PoeBuildCost.Repo.Migrations.CreateBuilds do
  use Ecto.Migration

  def change do
    create table(:builds) do
      add :url_prefix, :string, null: false
      add :password_hash, :string, default: nil

      timestamps()
    end
  end
end
