import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :logger,
       :console,
       # I like to remove the newline, which is there by default
       format: "[$level] $message $metadata\n"

config :memex,
  text_editor_shell_command: "vim"

config :memex,
  environment: %{
    name: "silbermm",
    memex_directory: "/Users/silbermm/Documents/memex/silbermm",
    backups_directory: "/Users/silbermm/Documents/memex/backups/silbermm"
  }

import_config "#{config_env()}.exs"
