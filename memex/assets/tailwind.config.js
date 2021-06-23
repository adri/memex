module.exports = {
  mode: "jit",
  purge: [
    "../lib/**/*.ex",
    "../lib/**/*.leex",
    "../lib/**/*.eex",
    "./js/**/*.js",
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
