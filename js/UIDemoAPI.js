//
// Pwsh UI Demo API
//

class UIDemoAPI {
    cs;

    constructor(port) {
        this.cs = new CommandScheduler(port);
    }

    Start() {
        this.cs.RegisterIncommingMessageHandler((m) => {
            console.log(`incomming message: ${m}`);
            ma1.innerText = m;
        });

        this.cs.Start('UIDemo1');
    }

    Close() { this.cs.Close(); }

    RunCommand() {
        ma1.innerText = '処理を実行しています。このままお待ちください';
        btnOK.disabled = 1;

        this.cs.SendCommand(
            "Run",
            { Id: textParamId.value, action: selAction.value }, (p) => {
                console.log(`Command:Run result ${p}`);
                ma1.innerText = p.msg;
                if (p.success != 1) {
                    m1.style.color = 'red';
                }

                btnOK.disabled = 1;
                btnCancel.value = '終了';
                btnCancel.disabled = 0;
                waitForClose = True;
            }
        );
    }
}