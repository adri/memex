import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import { InfiniteScroll } from "./infinite_scroll";
import { ForceInputValue } from "./force_input_value";
import { Sidebar } from "./sidebar";
import { Map } from "./map";
import { Editor } from "./editor";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { InfiniteScroll, ForceInputValue, Sidebar, Map, Editor },
  params: { _csrf_token: csrfToken },
});

liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

window.addEventListener("memex:clipcopy", (event) => {
  if ("clipboard" in navigator) {
    const text = event.target.textContent;
    navigator.clipboard.writeText(text);
  } else {
    alert("Sorry, your browser does not support clipboard copy.");
  }
});
