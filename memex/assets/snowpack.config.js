module.exports = {
  mount: {
    js: { url: "/js" },
    css: { url: "/css" },
    static: { url: "/", static: true, resolve: false },
  },
  buildOptions: {
    out: "../priv/static/",
  },
  plugins: ["@snowpack/plugin-postcss"],
  optimize: {
    entrypoints: ["./static/index.html"],
    bundle: true,
    minify: true,
    target: "es2018",
  },
};
