import * as React from "react";
import { render } from "react-dom";
import { Main } from "./main";
let el = document.querySelector("#app");
if (el) {
  render(<Main/>, el);
} else {
  console.warn("woops");
}
