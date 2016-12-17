// import * as React from "react";
import { h, Component } from "preact";
let ws_host = "ws://" + location.host + "/ws"
let ws = new WebSocket(ws_host);

let init_message = function () {
  return ({
    method: "browser_connect",
    params: [{}],
    id: guid()
  })
}

let guid = function () {
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1);
  }
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
    s4() + '-' + s4() + s4() + s4();
}

ws.onopen = function (event) {
  ws.send(JSON.stringify(init_message()));
};

ws.onmessage = function (message) {
  let data = JSON.parse(message.data);
  if (data.ping) {
    return;
  } else {
    handle_data(data);
  }
};

let handle_data = function (data: RpcMessage) {
  if (data.id == null) {
    // this is a notification.
    console.log("got an incoming notification");
    console.dir(data);
    return;
  } else {
    console.log("incoming message");
    console.dir(data);
    console.dir(data);
  }
}

type RpcMessage = RpcNotification | RpcRequest | RpcResponse
interface RpcNotification {
  method: string;
  params: [Object]
  id: string;
}

interface RpcRequest {
  method: string;
  params: [Object];
  id: null;
}

interface RpcResponse {
  results: any;
  error: null | any;
  id: string;
}

export class Main extends Component<{}, {}> {
  render() {
    return (
      <div>
        <h1> Configure your Farmbot! </h1>
        <div>
          <h2> Network </h2>
          <h3> SSID </h3>
          <input> something </input>
          <h3> Pass </h3>
          <input> asdf </input>

          <h2> Web App </h2>
          <h3> Email </h3>
          <input> </input>

          <h3> password </h3>
          <input> </input>

          <h3> server </h3>
          <input> </input>

          <h3> port </h3>
          <input> </input>
        </div>
      </div>
    );
  }
}
