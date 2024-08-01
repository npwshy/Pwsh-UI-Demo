/*
 * Command Scheduler
 */
class CommandScheduler {
    cws = null;
    IsReady = false;
    IsOpened = false;
    SeqNo = 0;
    Responders = [];
    InMsgResponder = null;

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
        if (resp.id == -1) {
            // this is special case; OOB/incomming message with no command associated
            this.ProcessIncommingMessage(resp);
            return;
        }
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

    ProcessIncommingMessage(r) {
        console.log(`Incomming Message: ${r.msg}`);
        if (this.InMsgResponder) {
            const cb = this.InMsgResponder;
            cb(r.msg);
        } else {
            console.log(`No responder registered for incomming message`)
        }
    }

    RegisterIncommingMessageHandler(cb) {
        this.InMsgResponder = cb;
    }
}