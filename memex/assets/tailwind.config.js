const colors = require("tailwindcss/colors");

module.exports = {
  mode: "jit",
  purge: [
    "../lib/**/*.ex",
    "../lib/**/*.leex",
    "../lib/**/*.heex",
    "../lib/**/*.eex",
    "./js/**/*.js",
  ],
  darkMode: "media", // false or 'media' or 'class'
  theme: {
    colors: {
      transparent: "transparent",
      current: "currentColor",
      black: colors.black,
      white: colors.white,
      gray: { ...colors.gray, '800': '#2c2b2b'},
      green: colors.green,
      indigo: colors.indigo,
      red: colors.rose,
      yellow: colors.amber,
    },
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
