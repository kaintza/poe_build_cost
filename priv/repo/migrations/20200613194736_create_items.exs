defmodule PoeBuildCost.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :search_id, :string, null: false
      add :slot, :integer, default: nil

      timestamps(updated_at: false)
    end

    create table(:build_items, primary_key: false) do
      add :item_id, :integer, null: false
      add :build_id, :integer, null: false
    end

    create index(:build_items, :item_id)
    create index(:build_items, :build_id)
    create unique_index(:build_items,
                        [:item_id, :build_id],
                        name: "ux_build_items")
  end
end
