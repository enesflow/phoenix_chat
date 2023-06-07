defmodule TwitterWeb.PageLive do
  use TwitterWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <h1>ChatLive</h1>
      <div
        class="messages"
        style="border: 1px solid #eee; height: 400px; overflow: scroll; margin-bottom: 8px;"
      >
        <%= for m <- @messages do %>
          <p style="margin: 2px;"><b><%= m.username %></b>: <%= m.text %></p>
        <% end %>
      </div>
      <.simple_form for={@form} phx-submit="send">
        <div class="flex flex-row">
          <!-- check if @form includes the errors key -->
          <.error :if={@form && @form.errors != []}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <input
            type="text"
            name="text"
            value={@text}
            class="flex-grow border border-gray-300 rounded-md px-3 py-2 mr-4 focus:outline-none focus:border-blue-300"
            required
          />
          <button
            phx-disable-with="Sending..."
            class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
          >
            Send <.icon name="hero-paper-airplane-solid" class="ml-2" />
          </button>
        </div>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: TwitterWeb.Endpoint.subscribe(topic())

    {:ok, assign(socket, text: "", username: username(), messages: []),
     temporary_assigns: [form: nil]}
  end

  defp username do
    "User #{:rand.uniform(1_000)}"
  end

  defp topic do
    "lobby"
  end

  def handle_info(%{event: "message", payload: message}, socket) do
    #  handle_info is ran for every message sent to the "lobby" topic
    {:noreply, assign(socket, messages: socket.assigns.messages ++ [message])}
  end

  def handle_event("send", %{"text" => text}, socket) do
    TwitterWeb.Endpoint.broadcast(topic(), "message", %{
      username: socket.assigns.username,
      text: text
    })

    {:noreply, assign(socket, text: "")}
  end
end
