defmodule QuickChatWeb.SvelteLive do
  use QuickChatWeb, :live_view

  def render(assigns) do
    ~H"""
    <.svelte name="Example" props={%{number: @number}} />
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, number: 42)}
  end

  def handle_event("set_number", %{"number" => number}, socket) do
    {:noreply, assign(socket, number: number)}
  end
end
