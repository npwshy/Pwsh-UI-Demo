/*
 * Command Scheduler
 */
class CommandScheduler {
    cws = null;
    IsReady = false;
    IsOpened = false;
    SeqNo = 0;
    Responders = [];

    constructor(port) {
        this.IsOpened = false;
        this.IsReady = false;
        this.SeqNo = 0;
        this.cws = new ClientWebSocket(port)
        this.Responders = [];
    }

    Start(subprotocol) {
        if (this.IsOpened || this.IsReady) {
            console.error(`CommandScheduler.Start: already started! isO=${this.IsOpened} IsR=${this.IsReady}`);
            return;
        }
        eventManager.Subscribe('ClientWebSocket.Ready', (m) => { this.SocketConnected(m); });
        eventManager.Subscribe('ClientWebSocket.OnMessage', (m) => { this.DispatchMessage(m); });
        this.cws.Connect(subprotocol);
        this.IsOpened = true;
    }

    SocketConnected(msg) {
        console.log(`SocketConnected: ready`);
        console.log(`IsReady=${this.IsReady}`);
        this.IsReady = true;
    }

    Close() {
        this.cws.SendMessage('!!TERMINATE!!');
    }

    SendCommand(c, p) { this.SendCommand(c, p, "none"); }
    SendCommand(c, p, cb) {
        var cmd = {
            id: this.SeqNo,
            cmd: c,
            param: p
        };
        this.SeqNo++;

        this.Responders[cmd.id] = cb;
        const str = JSON.stringify(cmd);
        console.log(`SendCommand: ${str}`);
        this.cws.SendMessage(str);
    }

    DispatchMessage(m) {
        const resp = JSON.parse(m);
        switch (this.Responders[resp.id]) {
            case undefined:
                console.error(`DispathMessage: Found reponse with no responder: ${m}`);
                break;
            case "none":
                // simply no responder defined/used
                break;
            default:
                const cb = this.Responders[resp.id];
                cb(resp.result);
                break;
        }
    }
}