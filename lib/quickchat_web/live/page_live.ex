defmodule QuickChatWeb.PageLive do
  use QuickChatWeb, :live_view
  alias QuickChat.Repo
  import Ecto.Query
  alias QuickChat.Message
  alias QuickChat.Chat
  alias QuickChat.Users.User

  def render(assigns) do
    ~H"""
    <.svelte
      name="Chat"
      props={%{chats: @chats, chat: @chat, messages: @messages, current_user: @current_user}}
    />
    """
  end

  defp convert_message_to_map(message) do
    %{
      id: message.id,
      body: message.body,
      inserted_at: message.inserted_at,
      user: %{
        id: message.user.id,
        email: message.user.email
      }
    }
  end

  defp convert_chats_to_map(chats) do
    Enum.map(chats, fn chat ->
      %{
        id: chat.id,
        title: chat.title,
        members: chat.members
      }
    end)
  end

  defp convert_chat_to_map(chat) do
    %{
      id: chat.id,
      title: chat.title,
      members: chat.members
    }
  end

  defp convert_current_user_to_map(user) do
    %{
      id: user.id,
      email: user.email
    }
  end

  def mount(_params, _session, socket) do
    chat = get_default_chat()
    if connected?(socket), do: QuickChatWeb.Endpoint.subscribe("chat:#{chat.id}")

    {:ok,
     assign(socket,
       text: "",
       username: socket.assigns[:current_user].email,
       # get_last_10_messages_for_chat(chat.id),
       # convert the above to a list of maps, avoid using Map.from_struct or anything like that
       # we will manually convert the structs to maps using %{} here:
       messages: get_last_10_messages_for_chat(chat.id) |> Enum.map(&convert_message_to_map/1),
       chat: convert_chat_to_map(chat),
       chats: get_all_chats() |> Enum.map(&convert_chat_to_map/1),
       current_user: convert_current_user_to_map(socket.assigns[:current_user])
     ), temporary_assigns: [form: nil]}
  end

  defp get_default_chat do
    #  I dont know if this is the best way to do this, but it works
    chat = Chat |> order_by(asc: :inserted_at) |> limit(1) |> Repo.one()

    case chat do
      nil ->
        chat = create_chat_with_random_title()
        Repo.insert!(chat)
        chat

      _ ->
        chat
    end
  end

  defp get_chat(id) do
    chat = Repo.get(Chat, id)

    case chat do
      nil ->
        chat = create_chat_with_random_title()
        Repo.insert!(chat)
        chat

      _ ->
        chat
    end
  end

  defp get_user_by_id(id) do
    Repo.get(User, id)
  end

  defp get_all_chats do
    Chat
    |> order_by(asc: :inserted_at)
    |> Repo.all()
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
    {:noreply,
     assign(socket, messages: socket.assigns.messages ++ [convert_message_to_map(message)])}
  end

  def handle_event("send", %{"text" => text}, socket) do
    # insert the message into the database
    message = %Message{
      user_id: socket.assigns.current_user.id,
      body: text,
      chat_id: socket.assigns.chat.id,
      user: get_user_by_id(socket.assigns.current_user.id)
    }

    Repo.insert!(message)

    QuickChatWeb.Endpoint.broadcast("chat:#{socket.assigns.chat.id}", "message", message)
    {:noreply, assign(socket, text: "")}
  end

  def handle_event("join", %{"chat_id" => chat_id}, socket) do
    # subscribe to the new chat, unsubscribe from the old one
    QuickChatWeb.Endpoint.unsubscribe("chat:#{socket.assigns.chat.id}")
    QuickChatWeb.Endpoint.subscribe("chat:#{chat_id}")

    {:noreply,
     assign(socket,
       chat: convert_chat_to_map(get_chat(chat_id)),
       messages: get_last_10_messages_for_chat(chat_id) |> Enum.map(&convert_message_to_map/1)
     )}
  end

  def handle_event("new_chat", _, socket) do
    chat = create_chat_with_random_title()

    case Repo.insert(chat) do
      {:ok, chat} ->
        #  subscribe to the new chat, unsubscribe from the old one
        QuickChatWeb.Endpoint.unsubscribe("chat:#{socket.assigns.chat.id}")
        QuickChatWeb.Endpoint.subscribe("chat:#{chat.id}")

        {:noreply,
         assign(socket,
           chat: convert_chat_to_map(chat),
           messages:
             get_last_10_messages_for_chat(chat.id) |> Enum.map(&convert_message_to_map/1),
           chats: socket.assigns.chats ++ [convert_chat_to_map(chat)]
         )}

      {:error, changeset} ->
        {:noreply, socket |> put_flash(:error, "Error creating chat")}
    end
  end
end
