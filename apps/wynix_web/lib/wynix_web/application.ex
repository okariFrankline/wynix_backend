defmodule WynixWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      WynixWeb.Telemetry,
      # Start the Endpoint (http/https)
      WynixWeb.Endpoint
      # Start a worker by calling: WynixWeb.Worker.start_link(arg)
      # {WynixWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WynixWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    WynixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
