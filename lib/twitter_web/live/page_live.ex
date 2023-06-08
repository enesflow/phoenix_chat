defmodule TwitterWeb.PageLive do
  use TwitterWeb, :live_view
  alias Twitter.Repo
  import Ecto.Query
  alias Twitter.Message
  alias Twitter.Chat
  alias Twitter.Users.User

  def render(assigns) do
    ~H"""
    <div>
      <ul class="flex flex-row">
        <%= for chat <- @chats do %>
          <li class="mr-4">
            <.link
              phx-click="join"
              phx-value-new-chat={chat.id}
              class="font-semibold text-brand hover:underline"
            >
              <%= chat.title %>
            </.link>
          </li>
        <% end %>
        <.button
          phx-click="new_chat"
          class="bg-blue-500 hover:bg-blue-700 text-white font-bold rounded"
        >
          New chat
        </.button>
      </ul>
      <h1>You are <b><%= @current_user.email %></b> in the chat <b><%= @chat.title %></b></h1>
      <div
        class="messages"
        style="border: 1px solid #eee; height: 400px; overflow: scroll; margin-bottom: 8px;"
      >
        <%= for m <- @messages do %>
          <p style="margin: 2px;"><b><%= m.user.email %></b>: <%= m.body %></p>
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
    if connected?(socket), do: TwitterWeb.Endpoint.subscribe("chat:#{get_chat(1).id}")

    {:ok,
     assign(socket,
       text: "",
       username: socket.assigns[:current_user].email,
       messages: get_last_10_messages_for_chat(1),
       chat: get_chat(1),
       chats: get_all_chats()
     ), temporary_assigns: [form: nil]}
  end

  defp get_chat(id) do
    Repo.get!(Chat, id)
  end

  defp get_all_chats do
    Repo.all(Chat)
  end

  defp get_last_10_messages_for_chat(chat_id) do
    Message
    |> where([m], m.chat_id == ^chat_id)
    |> limit(10)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  defp create_chat_with_random_title do
    %Chat{
      title: "Chat #{:rand.uniform(1000)}",
      members: []
    }
  end

  def handle_info(%{event: "message", payload: message}, socket) do
    #  handle_info is ran for every message sent to the "lobby" chat
    {:noreply, assign(socket, messages: socket.assigns.messages ++ [message])}
  end

  def handle_event("send", %{"text" => text}, socket) do
    # insert the message into the database
    message = %Message{
      user_id: socket.assigns.current_user.id,
      body: text,
      chat_id: socket.assigns.chat.id,
      user: socket.assigns.current_user
    }

    Repo.insert!(message)

    TwitterWeb.Endpoint.broadcast("chat:#{socket.assigns.chat.id}", "message", message)
    {:noreply, assign(socket, text: "")}
  end

  def handle_event("join", %{"new-chat" => new_chat}, socket) do
    # subscribe to the new chat, unsubscribe from the old one
    TwitterWeb.Endpoint.unsubscribe("chat:#{socket.assigns.chat.id}")
    TwitterWeb.Endpoint.subscribe("chat:#{new_chat}")

    {:noreply,
     assign(socket, chat: get_chat(new_chat), messages: get_last_10_messages_for_chat(new_chat))}
  end

  def handle_event("new_chat", _, socket) do
    chat = create_chat_with_random_title()
    Repo.insert!(chat)

    {:noreply, assign(socket, chats: socket.assigns.chats ++ [chat], chat: chat, messages: [])}
  end
end