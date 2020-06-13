defmodule PoeBuildCostWeb.ItemLive do
  @registry Registry.PoeBuildCost
  @supervisor PoeBuildCost.DynamicSupervisor

  use PoeBuildCostWeb, :live_view
  use Phoenix.HTML

  def mount(socket) do
    {:ok, assign(socket, show_modal: false, url: "", icon: "")}
  end

  def handle_event("save_url", %{"new_url" => %{"url" => new_url}}, socket) do
    handle_item(new_url)
    {:noreply, assign(socket, url: new_url, show_modal: false)}
  end

  def handle_event("open_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  def update(%{id: id, icon: icon}, socket) do
    {:ok, assign(socket, id: id, icon: icon)}
  end

  def update(%{id: id}, socket) do
    {:ok, assign(socket, id: id)}
  end

  def handle_info({PoeBuildCost.Item, "icon_change", %{icon: icon}}, socket) do
    require Logger
    Logger.info("aha2")
    {:noreply, assign(socket, icon: icon)}
  end

  defp handle_item(search_url) do
    search_id = search_url |> String.trim("/") |> String.split("/") |> List.last
    Phoenix.PubSub.subscribe(PoeBuildCost.PubSub, search_id)

    opts = [
      search_url: search_url,
      name: {:via, Registry, {@registry, search_id}}
    ]

    DynamicSupervisor.start_child(@supervisor, {PoeBuildCost.Item, opts})
  end
end
