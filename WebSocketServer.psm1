#
# WebSocket - Server
#

Set-StrictMode -Version latest

class WebSocketServer {
    [Byte[]] $Buffer;
    [ArraySegment[byte]] $Buffseg;
    $CancellationToken;
    $Listener;
    $HttpContext;
    $WebSocket;
    $SubProtocol = "Generic";

    Run($port, $handler, $sp) {
        $this.SubProtocol = $sp
        $this.Run($port, $handler)
    }

    Run($port, $handler) {
        $this.Prep($port)
        $this.Connect()

        while ($true) {
            $msg = $this.ReadMessage()
            if (-not $msg -or $msg -eq "!!TERMINATE!!") {
                log "TERMINATE command received. Terminating..."
                break
            }
            if (-not ($rc = $handler.ProcessMessage($msg))) {
                break
            }
            $this.SendMessage($rc)
        }
    }

    Connect() {
        log "Waiting for connection..."
        $this.HttpContext = $this.Listener.GetContext()
        log "Connection request: IsWebSocketRequest=$($this.HttpContext.Request.IsWebSocketRequest)"
        if (-not $this.HttpContext.Request.IsWebSocketRequest) {
            log "Not a Websocket request. Disconnecting..."
            $this.HttpContext.Response.StatusCode = 400
            $this.HttpContext.Response.Close()
            throw "Not a WebSocet connection"
        } else {
            $task = $this.HttpContext.AcceptWebSocketAsync($this.SubProtocol)
            $this.WaitTask($task, "AcceptWebSocketAsync")
            $wctx = $task.Result
            $this.WebSocket = $wctx.WebSocket
            $this.SendMessage("Hello, client!")
        }
    }

    [string] ReadMessage() {
        log "Receiving..."
        $task = $this.WebSocket.ReceiveAsync($this.Buffseg, $this.CancellationToken)
        #log "ReadMessage: ReceiveAsync returns $($task|ConvertTo-Json -Depth 2)"
        if ($task.IsFaulted) {
            return $null
        }

        $this.WaitTask($task, "ReadMessage")
        $r = $task.Result
        #log "ReadMessage: Count=$($r.Count) EoM=$($r.EndOfMessage)"
        $msg = [System.Text.Encoding]::UTF8.GetString($this.Buffer[0 .. ($r.Count - 1)])
        log "ReadMessage: $msg"
        return $msg
    }

    SendMessage($msg) {
        log "SendMessage: sending {$msg}"
        [ArraySegment[byte]]$asb = [System.Text.Encoding]::UTF8.GetBytes($msg)
        $task = $this.WebSocket.SendAsync($asb, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $this.CancellationToken)
        $this.WaitTask($task, "SendMessage")
        #log "SendMessage: Completed."
    }

    WaitTask($t, $m) {
        $t.Wait()
        #log "WaitTask: Task completed ($m) Completed?=$($t.IsCompleted) Faulted?=$($t.IsFaulted)"
    }

    Prep($port) {
        $this.CancellationToken = New-Object System.Threading.CancellationToken
        $this.Buffer = [byte[]]::New(4 * 1024)
        $this.Buffseg = New-Object ArraySegment[byte] -ArgumentList @(,$this.Buffer)

        $this.Listener = [System.Net.HttpListener]::New()
        $this.Listener.Prefixes.Add("http://localhost:$($port)/")
        $this.Listener.Start()
    }
}