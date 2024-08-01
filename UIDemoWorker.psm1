#
# UI Demo API Worker module
#
using module .\lib.pwsh\stdps.psm1
using module .\WSCommandDispatcher.psm1

class DemoWorker {
    $OOBSender;

    Init([WSCommandDispatcher]$dispatcher) {
        $dispatcher.RegisterCommand("Run", $this.RunCommand)
        $this.OOBSender = $dispatcher.SendOOBMessage;
    }

    [Object] RunCommand($p) {
        <#
            p.param.Id <-- paramId
            p.param.action <-- action code (there should be no Noop)
        #>
        log "RunCommand: Id=$($p.param.Id) Action=$($p.param.action)"

        $w = 5;
        log "RunCommand: Processing now... ($w sec. 1/2)"
        Start-Sleep -s $w

        $this.SendStatus("ただいま処理中...")

        log "RunCommand: Processing now... ($w sec. 2/2)"
        Start-Sleep -s $w

        $rc =  @{
            success = 1;
            msg = "処理は正常に完了しました。終了ボタンを押してブラウザのタブを閉じてください"
        }
        return $rc
    }

    SendStatus([string]$m) {
        $this.OOBSender.Invoke($m)
    }
}