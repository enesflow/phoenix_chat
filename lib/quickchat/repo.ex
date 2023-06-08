defmodule QuickChat.Repo do
  use Ecto.Repo,
    otp_app: :quickchat,
    adapter: Ecto.Adapters.Postgres
end
