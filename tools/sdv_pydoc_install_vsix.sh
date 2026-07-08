#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VSCODE_DIR="${ROOT_DIR}/vscode"

if [[ $# -gt 1 ]]; then
	echo "Usage: $0 [vsix-file]"
	exit 1
fi

if [[ $# -eq 1 ]]; then
	VSIX_PATH="$1"
else
	if ! command -v jq >/dev/null 2>&1; then
		echo "jq not found on PATH"
		exit 1
	fi
	if [[ ! -f "${VSCODE_DIR}/package.json" ]]; then
		echo "package.json not found: ${VSCODE_DIR}/package.json"
		exit 1
	fi
	VERSION="$(jq -r .version "${VSCODE_DIR}/package.json")"
	if [[ -z "${VERSION}" || "${VERSION}" == "null" ]]; then
		echo "could not read version from ${VSCODE_DIR}/package.json"
		exit 1
	fi
	VSIX_PATH="${VSCODE_DIR}/tde4-pydoc-${VERSION}.vsix"
fi

if [[ ! -f "${VSIX_PATH}" ]]; then
	echo "VSIX file not found: ${VSIX_PATH}"
	exit 1
fi

echo "Installing ${VSIX_PATH}"
code --install-extension "${VSIX_PATH}" --force
