defmodule PoeBuildCostSchema.Item do
  use PoeBuildCostSchema.Base, :schema

  schema "items" do
    field(:search_id, :string)
    field(:slot, :integer)

    many_to_many(
      :builds,
      PoeBuildCostSchema.Build,
      join_through: "build_items",
      on_replace: :delete
    )

    timestamps(updated_at: false)
  end

  def insert_changeset(item \\ %__MODULE__{}, attrs) do
    item
    |> cast(attrs, ~w(search_id slot)a)
    |> unique_constraint([:search_id, :slot])
    |> validate_required(~w(search_id slot)a)
  end
end
