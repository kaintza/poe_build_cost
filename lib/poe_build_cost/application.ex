defmodule PoeBuildCost.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      PoeBuildCost.Repo,
      # Start the Telemetry supervisor
      PoeBuildCostWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: PoeBuildCost.PubSub},
      # Start the Endpoint (http/https)
      PoeBuildCostWeb.Endpoint,
      # Start a worker by calling: PoeBuildCost.Worker.start_link(arg)
      # {PoeBuildCost.Worker, arg}
      {DynamicSupervisor, strategy: :one_for_one, name: PoeBuildCost.DynamicSupervisor},
      {Registry, keys: :unique, name: Registry.PoeBuildCost}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PoeBuildCost.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PoeBuildCostWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
