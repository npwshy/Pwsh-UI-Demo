#
# Pwsh UI Demo
#
using module .\lib.pwsh\stdps.psm1
using module .\lib.pwsh\AppEnv.psm1
using module .\UIGen.psm1
using module .\WebSocketServer.psm1
using module .\WSCommandDispatcher.psm1
using module .\UIDemoWorker.psm1

param(
[int] $Port = 4000,
[string] $ConfigFile = "appconfig.json",
[string] $LogFile = "logs\log.txt",
[int] $LogGenerations = 9,
[switch] $AppendLog,
[switch] $Help
)

Set-StrictMode  -Version latest
$ErrorActionPreference = "stop"

RunApp ([Main]::New()) $LogFile $LogGenerations $AppendLog
return;

class Main {
    $Browser;
    $DemoHelper;
    $Dispatcher;

    Run() {
        $this.Init()

        $p = [UIGenParams]::New()
        $p.Title = 'Pwsh UI Demo'
        $p.OutPath = 'demo.html'
        $p.Port = $this.GetAvailablePort()
        $g = [UIGen]::New()
        $g.Generate($p)

        & $this.Browser ([IO.Path]::GetFullPath($p.OutPath))

        $server = [WebSocketServer]::New()
        $this.Dispatcher.RegisterOOBSender($server.SendMessage);
        $server.Run($p.Port, $this.Dispatcher, 'UIDemo1')
    }

    [int] GetAvailablePort() {
        return $script:Port
    }

    Init() {
        [AppEnv]::Init($script:ConfigFile)

        $this.Browser = [AppEnv]::Get('Browser')
        $this.Dispatcher = [WSCommandDispatcher]::New()
        $this.Dispatcher.Init()

        $this.DemoHelper = [DemoWorker]::New()
        $this.DemoHelper.Init($this.Dispatcher)
    }
}