#
# WebSocket Command Dispatcher
#

class WSCommandDispatcher {
    $DispatchTable;
    $OOBSender; # cb function to use out-of-band message to browser

    # ProcessMessage is called by SocketServer for msg recieved from client
    # and expected to return result as string.
    # Incoming message is json format of command and parameters.
    [string] ProcessMessage([string]$msg) {
        $req = $msg |ConvertFrom-Json -AsHashtable
        # here req will look like:
        # @{id=<int>; cmd=[string]; params=null or anything}

        $cmd = $req.cmd;
        if ($this.DispatchTable.Contains($cmd)) {
            $cb = $this.DispatchTable.$cmd
            $rc = $cb.Invoke($req)
            $req.result = $rc
        } else {
            # no handler registered -> log it, return something as client is waiting for response
            log "$($this.GetType().Name).ProcessMessage: No hanlder resigtered for command: $cmd"
            $req.result = @{ msg="ERROR! Command not found: $cmd" }
        }
        return $req |ConvertTo-Json -Depth 10 -Compress
    }

    RegisterCommand([string]$cmd, $handler) {
        $this.DispatchTable.$cmd = $handler
    }

    Init() {
        $this.DispatchTable = @{}
    }

    RegisterOOBSender($cb) {
        $this.OOBSender = $cb;
    }

    SendOOBMessage([string]$msg) {
        $pac = @{}
        $pac.id = -1
        $pac.msg = $msg
        $txt = $pac |ConvertTo-Json -Depth 10 -Compress
        $this.OOBSender.Invoke($txt)
    }
}