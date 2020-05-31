defmodule PoeBuildCost.Repo do
  use Ecto.Repo,
    otp_app: :poe_build_cost,
    adapter: Ecto.Adapters.Postgres
end
