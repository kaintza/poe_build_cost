defmodule PoeBuildCostWeb.ItemLive do
  @registry Registry.PoeBuildCost
  @supervisor PoeBuildCost.DynamicSupervisor

  use PoeBuildCostWeb, :live_view
  use Phoenix.HTML

  def mount(_params, %{"slot" => slot, "build" => nil}, socket) do
    {:ok, assign(socket, show_modal: false, url: "", item: nil, icon: "", id: nil, slot: slot, build: nil)}
  end

  def mount(_params, %{"slot" => slot, "build" => build}, socket) do
    slots = [helmet: 1, chest: 2, belt: 3, weapon_left: 4, weapon_right: 5, gloves: 6]
    item = build.items |> Enum.find(fn %{slot: repo_slot} -> slots[slot] == repo_slot end)

    if item, do: start_watch(item.search_id)
    {:ok, assign(socket, show_modal: false, url: item && search_url(item.search_id), icon: "", id: nil, slot: slot, build: build, item: item)}
  end

  def search_url(search_id) do
    "https://www.pathofexile.com/trade/search/Delirium/#{search_id}"
  end

  def handle_event("save_url", %{"new_url" => %{"url" => new_url}}, socket = %{assigns: %{ build: nil, slot: slot }}) do
    build = insert_build()
    handle_item(new_url, slot, build)
    {:noreply, socket |> redirect(to: Routes.build_path(PoeBuildCostWeb.Endpoint, :show, build.url_prefix))}
  end

  def handle_event("save_url", %{"new_url" => %{"url" => new_url}}, socket = %{assigns: %{ build: build, slot: slot }}) do
    item = handle_item(new_url, slot, build)
    {:noreply, assign(socket, url: new_url, item: item, show_modal: false)}
  end

  def handle_event("open_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  def handle_info({PoeBuildCost.Item, "icon_change", %{icon: icon}}, socket) do
    require Logger
    Logger.info("aha2")
    {:noreply, assign(socket, icon: icon)}
  end

  defp handle_item(search_url, slot, build) do
    search_id = search_url |> String.trim("/") |> String.split("/") |> List.last

    Phoenix.PubSub.subscribe(PoeBuildCost.PubSub, search_id)

    item = insert_item(search_id, slot, build)

    opts = [
      search_url: search_url,
      name: {:via, Registry, {@registry, search_id}}
    ]

    DynamicSupervisor.start_child(@supervisor, {PoeBuildCost.Item, opts})

    item
  end

  defp start_watch(search_id) do
    require Logger
    Logger.info("ahamm3")
    Phoenix.PubSub.subscribe(PoeBuildCost.PubSub, search_id)
    search_url = "https://www.pathofexile.com/trade/search/Delirium/#{search_id}"
    opts = [
      search_url: search_url,
      name: {:via, Registry, {@registry, search_id}}
    ]

    DynamicSupervisor.start_child(@supervisor, {PoeBuildCost.Item, opts})
  end

  def insert_build do
    length = 12
    url_prefix = :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
    attributes = %{ url_prefix: url_prefix }

    PoeBuildCostSchema.Build.insert_changeset(attributes) |> PoeBuildCost.Repo.insert!
  end

  def insert_item(search_id, slot, build) do
    slots = [helmet: 1, chest: 2, belt: 3, weapon_left: 4, weapon_right: 5, gloves: 6]
    attributes = %{
      search_id: search_id,
      slot: slots[slot]
    }

    item =
      PoeBuildCostSchema.Item.insert_changeset(attributes)
      |> PoeBuildCost.Repo.insert
      |> case do
          {:ok, item} -> item
          {:error, _} -> PoeBuildCost.Repo.get_by!(PoeBuildCostSchema.Item, slot: slots[slot], search_id: search_id)
          end

    build |> PoeBuildCost.Repo.preload(:items) |> PoeBuildCostSchema.Build.update_items_changeset([item]) |> PoeBuildCost.Repo.update!
  end
end
