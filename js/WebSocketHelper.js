/*
 * WebSocketHelper
*/
class ClientWebSocket {
    IsConnected;
    IsReady;
    Port;
    ws;
    serverHello;

    constructor(port) {
        this.Port = port;
        this.IsConnected = false;
        this.IsReady = false;
        this.serverHello = false;

        eventManager.NewEvent('ClientWebSocket.Ready');
        eventManager.NewEvent('ClientWebSocket.OnMessage');
    }

    Connect(subprotocol) {
        if (this.IsConnected) {
            console.error(`ClientWebSocet.Connect: already connected`);
            return;
        }
        console.log(`Connecting to port ${this.Port}...`);
        this.ws = new WebSocket(`ws://localhost:${this.Port}/`, subprotocol);
        this.IsConnected = true;

        this.ws.onopen = function(e) {
            console.log(`Connection opened!`);
            this.IsReady = true;
        }

        this.ws.onmessage = (e) => {
            var msg = e.data;
            console.log(`ClientWebSocket message=${msg}`);
            if (!this.serverHello && msg == 'Hello, client!') {
                this.serverHello = true;
                this.IsReady = true;
                console.log(`ClientWebSocket: Connected!`);
                eventManager.TriggerEvent('ClientWebSocket.Ready', '');
            } else {
                eventManager.TriggerEvent('ClientWebSocket.OnMessage', msg)
            }
        }
    }

    SendMessage(msg) {
        if (!this.IsReady) {
            console.error(`Socket is not ready`);
            return;
        }
        this.ws.send(msg);
        console.log(`SendMessage: sent messasge: ${msg}`)
    }
}
