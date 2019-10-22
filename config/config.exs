import Config

config :appsignal, :config,
  active: true,
  name: "AppsignalHammer",
  # Randomly generated, garbage uuid as the push key
  push_api_key: "a99a058a-f7a8-4efe-845a-5b6d36156697",
  env: Mix.env()

config :logger, level: :debug
