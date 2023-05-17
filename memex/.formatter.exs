[
  surface_inputs: ["{lib,test}/**/*.{ex,exs,sface}"],
  import_deps: [:ecto, :phoenix, :surface],
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"],
  plugins: [
    Surface.Formatter.Plugin,
    Phoenix.LiveView.HTMLFormatter
  ]
]
