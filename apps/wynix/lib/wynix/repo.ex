defmodule Wynix.Repo do
  use Ecto.Repo,
    otp_app: :wynix,
    adapter: Ecto.Adapters.Postgres
end
