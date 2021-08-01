// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import { InfiniteScroll } from "./infinite_scroll";
import { ForceInputValue } from "./force_input_value";
import { Sidebar } from "./sidebar";
import { Map } from "./map";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { InfiniteScroll, ForceInputValue, Sidebar, Map },
  params: { _csrf_token: csrfToken },
});
// connect if there are any LiveViews on the page
liveSocket.connect();

// Show progress bar on live navigation and form submits
// let progressTimeout = null;
// window.addEventListener("phx:page-loading-start", () => {
//   clearTimeout(progressTimeout);
//   progressTimeout = setTimeout(NProgress.start, 100);
// });
// window.addEventListener("phx:page-loading-stop", () => {
//   clearTimeout(progressTimeout);
//   NProgress.done();
// });

// import NProgress from "nprogress";

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

import "mapbox-gl";
