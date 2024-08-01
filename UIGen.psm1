#
# UI Page Generator
#
using module .\lib.pwsh\stdps.psm1
using module .\lib.pwsh\AppEnv.psm1
using module .\lib.pwsh\HTMLGenerator.psm1

class UIGenParams : HTMLGenParams {
    [int] $Port;
}

class UIGen : HTMLGenerator {
    AddBodyScript() {
        $dir = [AppEnv]::Get('HTML.JS.Dir')
        $jsfiles = [AppEnv]::Get('HTML.BddyJS.Files') -split(',')

        foreach ($f in $jsfiles) {
            $fp = Join-Path $dir "$f.js"
            $this.Code += @"
/*
 * $f
 */
"@

            $this.Code += Get-Content $fp
            $this.Code += @"
/*** end of $f ***/

"@
        }
    }

    [string] PostProcess([string]$txt) {
        $txt = $txt -replace '___PORT___', $this.Param.Port;
        return $txt
    }
}
