defmodule TwitterWeb.PageLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <div>
    <h1>ChatLive</h1>
    <div class="messages" style="border: 1px solid #eee; height: 400px; overflow: scroll; margin-bottom: 8px;">
    <%= for m <- @messages do %>
      <p style="margin: 2px;"><b><%= m.username %></b>: <%= m.text %></p>
    <% end %>
    </div>
    <form phx-submit="send">
    <input type="text" name="text" />
    <button type="submit">Send</button>
    </form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: TwitterWeb.Endpoint.subscribe(topic)
    {:ok, assign(socket, username: username, messages: [])}
  end

  defp username do
    "User #{:rand.uniform(1_000)}}"
  end

  defp topic do
    "lobby"
  end

  def handle_info(%{event: "message", payload: message}, socket) do
    #  handle_info is ran for every message sent to the "lobby" topic
    {:noreply, assign(socket, messages: socket.assigns.messages ++ [message])}
  end

  def handle_event("send", %{"text" => text}, socket) do
    TwitterWeb.Endpoint.broadcast(topic, "message", %{
      username: socket.assigns.username,
      text: text
    })

    {:noreply, assign(socket, text: "")}
  end
end
