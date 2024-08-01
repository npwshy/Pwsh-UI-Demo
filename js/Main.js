
function init() {
    initvar();

    btnCancel.onclick = e => {
        api.Close();
        window.close();
    };
    textParamId.onchange = e => { btnOK.disabled = !isReadyToSubmit(); };
    selAction.onchange = e => { btnOK.disabled = !isReadyToSubmit(); };

    btnOK.onclick = e => {
        api.RunCommand();
    }
}

function initvar() {
    api = new UIDemoAPI(___PORT___);


    btnOK = document.getElementById('buttonOK');
    btnCancel = document.getElementById('buttonCancel');

    textParamId = document.getElementById('paramId');
    selAction = document.getElementById('selAction');

    waitForClose = false;
}

function isReadyToSubmit() {
    if (waitForClose) {
        return falsel;
    }
    return (textParamId.value != '' && selAction.value != 'Noop')
}

function main() {
    init();
    api.Start();
}

main();