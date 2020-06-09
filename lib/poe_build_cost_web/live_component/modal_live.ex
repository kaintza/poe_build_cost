defmodule PoeBuildCost.LiveComponent.ModalLive do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{url: url} = assigns, socket) do
    {:ok, assign(socket, url: url)}
  end
end
