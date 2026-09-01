const vscode = require('vscode');
const path = require('path');
const fs = require('fs');

function activate(context) {
    const disposable = vscode.commands.registerCommand('claudeAbliterated.open', async () => {
        const workspaceFolder = vscode.workspace.workspaceFolders?.[0]?.uri?.fsPath;
        if (!workspaceFolder) {
            vscode.window.showErrorMessage('No workspace folder found');
            return;
        }

        const scriptPath = path.join(__dirname, 'claude-abliterated.ps1');
        if (!fs.existsSync(scriptPath)) {
            vscode.window.showErrorMessage(`claude-abliterated.ps1 not found at ${scriptPath}`);
            return;
        }

        const terminal = vscode.window.createTerminal({
            name: 'Claude Abliterated',
            cwd: workspaceFolder,
            iconPath: vscode.Uri.joinPath(context.extensionUri, 'resources', 'red-icon.svg'),
            isTransient: false
        });
        terminal.show();

        setTimeout(() => {
            terminal.sendText(`& "${scriptPath.replace(/\\/g, '\\\\')}"`);
        }, 500);
    });

    context.subscriptions.push(disposable);
}

function deactivate() {}

module.exports = { activate, deactivate };
