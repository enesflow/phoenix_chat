defmodule Twitter.Repo do
  use Ecto.Repo,
    otp_app: :twitter,
    adapter: Ecto.Adapters.Postgres
end
