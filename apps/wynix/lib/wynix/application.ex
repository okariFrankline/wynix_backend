defmodule Wynix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Wynix.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Wynix.PubSub}
      # Start a worker by calling: Wynix.Worker.start_link(arg)
      # {Wynix.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Wynix.Supervisor)
  end
end
