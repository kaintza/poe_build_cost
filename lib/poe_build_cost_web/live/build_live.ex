defmodule PoeBuildCostWeb.BuildLive do

  use PoeBuildCostWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, show_modal: false, items: %{})}
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
