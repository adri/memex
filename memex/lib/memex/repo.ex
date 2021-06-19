defmodule Memex.Repo do
  use Ecto.Repo,
    otp_app: :memex,
    adapter: Ecto.Adapters.Postgres
end
