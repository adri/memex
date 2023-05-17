[
  surface_inputs: ["{lib,test}/**/*.{ex,exs,sface}"],
  import_deps: [:ecto, :ecto_sql, :phoenix, :surface],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"],
  subdirectories: ["priv/*/migrations"],
  plugins: [
    Surface.Formatter.Plugin,
    Phoenix.LiveView.HTMLFormatter
  ]
]
