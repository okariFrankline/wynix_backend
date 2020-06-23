# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :wynix,
  ecto_repos: [Wynix.Repo]

config :wynix_web,
  ecto_repos: [Wynix.Repo],
  generators: [context_app: :wynix, binary_id: true]

# Configures the endpoint
config :wynix_web, WynixWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/seGC81BiEVzZSDzAOeed9i7XLA+qeAE/YtDBoC9MQhEOuT01VX7sD50unK+o/4/",
  render_errors: [view: WynixWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Wynix.PubSub,
  live_view: [signing_salt: "Ct46PwcC"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
