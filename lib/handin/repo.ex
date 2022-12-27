defmodule Handin.Repo do
  use Ecto.Repo,
    otp_app: :handin,
    adapter: Ecto.Adapters.Postgres
end
