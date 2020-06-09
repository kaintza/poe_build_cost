defmodule PoeBuildCost.LiveComponent.ItemComponent do
  @registry Registry.PoeBuildCost
  @supervisor PoeBuildCost.DynamicSupervisor

  use Phoenix.LiveComponent
  use Phoenix.HTML

  def mount(socket) do
    {:ok, assign(socket, show_modal: false, url: "")}
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

  def update(%{id: id}, socket) do
    {:ok, assign(socket, id: id)}
  end

  defp handle_item(search_id) do
     opts = [
      search_id: search_id,
      name: {:via, Registry, {@registry, search_id}}
    ]

    DynamicSupervisor.start_child(@supervisor, {PoeBuildCost.Item, opts})
  end
end
