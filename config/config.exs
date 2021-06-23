# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :weather_scout, WeatherScoutWeb.Endpoint,
  url: [host: "theweatherscout.com" || "localhost"],
  # add in your apps secret key base here
  secret_key_base: "YOURSECRETKEYBASEGOESHERE",
  render_errors: [view: WeatherScoutWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: WeatherScout.PubSub,
  live_view: [signing_salt: "R9QgEJbs"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
