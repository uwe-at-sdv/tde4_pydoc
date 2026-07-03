#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VSCODE_DIR="${ROOT_DIR}/vscode"

if [[ $# -gt 1 ]]; then
	echo "Usage: $0 [pat-file]"
	exit 1
fi

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
PAT_FILE="${1:-${ROOT_DIR}/../../sdv_doc_waterloo/TOKEN_MARKETPLACE}"

if [[ ! -f "${VSIX_PATH}" ]]; then
	echo "VSIX file not found: ${VSIX_PATH}"
	exit 1
fi
if [[ ! -f "${PAT_FILE}" ]]; then
	echo "PAT file not found: ${PAT_FILE}"
	echo "Publishing is done by SDV only."
	exit 1
fi

VSCE_PAT="$(tr -d '\r\n' < "${PAT_FILE}")"
if [[ -z "${VSCE_PAT}" ]]; then
	echo "PAT file is empty: ${PAT_FILE}"
	exit 1
fi

echo "Publishing ${VSIX_PATH}"
"${ROOT_DIR}/tools/sdv_pydoc_render_readmes.sh"

vsce publish -p "${VSCE_PAT}" -i "${VSIX_PATH}"
