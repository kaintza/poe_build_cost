# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :poe_build_cost, PoeBuildCost.Repo,
  database: "poe_build_cost_repo",
  username: "postgres",
  password: "asdqwe",
  hostname: "localhost"

config :poe_build_cost,
  ecto_repos: [PoeBuildCost.Repo]

# Configures the endpoint
config :poe_build_cost, PoeBuildCostWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rfmyvmcsCBvIX5sQVUPxNqwukrJ7Oc8bYC6fk1iOgLUyIJa3EtbTZwjOb4VC1jBV",
  render_errors: [view: PoeBuildCostWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PoeBuildCost.PubSub,
  live_view: [signing_salt: "gjcRUVfS"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
