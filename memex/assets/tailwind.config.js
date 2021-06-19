module.exports = {
  mode: "jit",
  purge: [
    "../**/*.{html.eex,html.leex,ex,exs,js}",
    "../**/*/*.{html.eex,html.leex,ex,exs,js}",
  ],
  darkMode: "media", // false or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
