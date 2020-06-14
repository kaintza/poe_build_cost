defmodule PoeBuildCostSchema.Build do
  use PoeBuildCostSchema.Base, :schema

  schema "builds" do
    field(:url_prefix, :string)
    field(:password_hash, :string)

    many_to_many(
      :items,
      PoeBuildCostSchema.Item,
      join_through: "build_items",
      on_replace: :delete
    )

    timestamps()
  end

  def insert_changeset(build \\ %__MODULE__{}, attrs) do
    build
    |> cast(attrs, ~w(url_prefix)a)
    |> validate_required(~w(url_prefix)a)
  end

  @required_fields ~w(id)a
  def update_items_changeset(build, items) do
    build
    |> cast(%{}, @required_fields)
    |> put_assoc(:items, items)
  end
end
