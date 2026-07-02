'use strict';

const child_process = require('child_process');
const fs = require('fs');
const path = require('path');
const vscode = require('vscode');

const fout = vscode.window.createOutputChannel('Channel.3DE4 Python API');

function getWorkspaceRoot() {
	const folders = vscode.workspace.workspaceFolders || [];
	return folders.length > 0 ? folders[0].uri.fsPath : null;
}

function resolveConfigPath(extensionPath) {
	const cfg = vscode.workspace.getConfiguration('tde4');
	const configured = String(cfg.get('mcpConfigPath', '')).trim();
	if (configured) {
		return configured;
	}
	if (extensionPath) {
		const bundled = path.join(extensionPath, 'etc', 'wtrl_mcp.stdio.toml');
		if (fs.existsSync(bundled)) {
			return bundled;
		}
	}
	const root = getWorkspaceRoot();
	if (root) {
		const candidate = path.join(root, 'etc', 'wtrl_mcp.stdio.toml');
		if (fs.existsSync(candidate)) {
			return candidate;
		}
	}
	return 'etc/wtrl_mcp.stdio.toml';
}

function createMcpServerDefinition(extensionPath) {
	const cfg = vscode.workspace.getConfiguration('tde4');
	const command = String(cfg.get('mcpCommand', 'wtrl_mcp')).trim() || 'wtrl_mcp';
	const label = String(cfg.get('mcpServerLabel', '3DE4 Python API (stdio)')).trim() || '3DE4 Python API (stdio)';
	const configPath = resolveConfigPath(extensionPath);
	fout.appendLine(`3DE4 Python API MCP provider: advertising '${label}' via '${command} --config ${configPath}'.`);
	return new vscode.McpStdioServerDefinition(label, command, ['--config', configPath]);
}

function formatMcpPreflightFailure(command, configPath, err) {
	const stderr = err && typeof err.stderr === 'string' ? err.stderr.trim() : '';
	const stdout = err && typeof err.stdout === 'string' ? err.stdout.trim() : '';
	const status = typeof err?.status === 'number' ? String(err.status) : 'unknown';
	const signal = typeof err?.signal === 'string' ? err.signal : '';
	const parts = [];
	parts.push(`-- MCP preflight failed for '${command} --config ${configPath} --gen-config-template'.`);
	if (status !== 'unknown') {
		parts.push(`Exit status: ${status}${signal ? ` (signal: ${signal})` : ''}.`);
	}
	parts.push('');
	parts.push('This usually means that the executable starts, but the Python environment behind it cannot import sdv.doc.waterloo or one of its MCP resources.');
	parts.push('');
	parts.push('Check the environment that provides wtrl_mcp and install sdv-doc-waterloo there.');
	parts.push('If you run the command manually, the same failure should appear in the terminal.');
	if (stderr) {
		parts.push('');
		parts.push('stderr:');
		parts.push(stderr);
	}
	if (stdout) {
		parts.push('');
		parts.push('stdout:');
		parts.push(stdout);
	}
	return parts.join('\n');
}

function runMcpPreflight(command, configPath) {
	try {
		child_process.execFileSync(command, ['--config', configPath, '--gen-config-template'], {
			encoding: 'utf-8',
			timeout: 5000,
			stdio: ['ignore', 'pipe', 'pipe'],
		});
		return { ok: true };
	}
	catch (err) {
		return { ok: false, detail: formatMcpPreflightFailure(command, configPath, err) };
	}
}

function registerMcpProvider(context) {
	fout.appendLine('Activating 3DE4 Python API extension...');
	if (!vscode.lm || typeof vscode.lm.registerMcpServerDefinitionProvider !== 'function') {
		fout.appendLine('3DE4 Python API MCP provider: VS Code MCP API not available in this host/version.');
		return;
	}
	fout.appendLine('3DE4 Python API MCP provider: MCP API available.');

	const cfg = vscode.workspace.getConfiguration('tde4');
	if (cfg.get('mcpProvideServer', true) !== true) {
		fout.appendLine('3DE4 Python API MCP provider: disabled by setting tde4.mcpProvideServer.');
		return;
	}

	const command = String(cfg.get('mcpCommand', 'wtrl_mcp')).trim() || 'wtrl_mcp';
	const configPath = resolveConfigPath(context.extensionPath);
	const preflight = runMcpPreflight(command, configPath);
	if (!preflight.ok) {
		fout.appendLine('3DE4 Python API MCP provider: preflight failed.');
		fout.appendLine(preflight.detail);
		fout.appendLine('3DE4 Python API MCP provider: the server definition is still registered, but startup is likely to fail until the environment is fixed.');
		vscode.window.showWarningMessage('3DE4 Python API: MCP preflight failed. Open the Output channel for details.');
	}

	const provider = {
		provideMcpServerDefinitions: () => [createMcpServerDefinition(context.extensionPath)],
	};

	const disposable = vscode.lm.registerMcpServerDefinitionProvider('tde4_pydoc.mcpProvider', provider);
	context.subscriptions.push(disposable);
	fout.appendLine('3DE4 Python API MCP provider: registered.');
}

function activate(context) {
	context.subscriptions.push(fout);
	fout.show(true);
	registerMcpProvider(context);
}

function deactivate() {}

module.exports = {
	activate,
	deactivate,
};
