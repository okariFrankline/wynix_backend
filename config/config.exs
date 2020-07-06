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

config :wynix_web, WynixWeb.Authentication.Guardian,
  # optional
  allowed_algos: ["ES512"],
  # optional
  verify_module: Guardian.JWT,
  issuer: "Ejob",
  ttl: {30, :days},
  allowed_drift: 2000,
  # optional
  verify_issuer: true,
  # generated using: JOSE.JWS.generate_key(%{"alg" => "ES512"}) |> JOSE.JWK.to_map |> elem(1)
  secret_key: %{
    "crv" => "P-521",
    "d" => "AYRmr07ucv_9cEsxpQBFgIiJM9-SR9sK4seFqCmu5ZNVP7WJa6_6Evg_h6YDq42V2tw_fTJ8ZxUWooUbToLvKpdp",
    "kty" => "EC",
    "x" => "AFJpzJdjImNkcSjmTsVYjS5KbTQqWIC4mtIYS-vCl4nkwXPQgMumMOdLlxEO_pW8RNOecZSSB_gqmtXk2xgqLgAi",
    "y" => "AA3FVnldZYI2NynHfzRcE-YqFxhHbab1VV8B2f9odZik7UWBwLkBcUACObVMV0EuzuLmt3DggyPyNwUQPqdPaG5p"
  },
  serializer: WynixWeb.Authentication.Guardian

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
