import { render, h } from "preact";
import { Main } from "./main";
import "../css/main.scss"

let el = document.querySelector("#app");
if (el) {
  render(<Main />, el);
} else {
  console.warn("woops");
}
