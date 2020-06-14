defmodule PoeBuildCostWeb.BuildLive do
  use PoeBuildCostWeb, :live_view
  alias PoeBuildCostWeb.LiveComponent.ItemComponent

  @impl true
  def mount(%{"build_url" => build_url}, _session, socket) do
    build = PoeBuildCostSchema.Build |> PoeBuildCost.Repo.get_by!(url_prefix: build_url) |> PoeBuildCost.Repo.preload(:items)
    {:ok, assign(socket, show_modal: false, slots: slots(), build: build)}
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, show_modal: false, slots: slots(), build: nil)}
  end

  def slots do
    [:helmet, :chest, :belt, :amulet, :weapon_left, :weapon_right, :ring_left, :ring_right, :gloves, :boots, :flask1, :flask2, :flask3, :flask4, :flask5]
  end


  def handle_params(%{id: id}, socket) do
  end

  def handle_event("open_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: true)}
    #item = handle_item(search_id)
    #{:noreply, socket |> assign(items: %{})}
  end

  def handle_event("add_url", %{"search_id" => search_id}, socket) do
    {:noreply, assign(socket, show_modal: true)}
    #item = handle_item(search_id)
    #{:noreply, socket |> assign(items: %{})}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: false)}
    #item = handle_item(search_id)
    #{:noreply, socket |> assign(items: %{})}
  end
end
