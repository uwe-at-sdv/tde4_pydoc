#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -lt 1 || $# -gt 2 ]]; then
	echo "Usage: $0 <vsix-file> [pat-file]"
	exit 1
fi

VSIX_PATH="$1"
PAT_FILE="${2:-${ROOT_DIR}/../../sdv_doc_waterloo/TOKEN_MARKETPLACE}"

if [[ ! -f "${VSIX_PATH}" ]]; then
	echo "VSIX file not found: ${VSIX_PATH}"
	exit 1
fi
if [[ ! -f "${PAT_FILE}" ]]; then
	echo "PAT file not found: ${PAT_FILE}"
	exit 1
fi

VSCE_PAT="$(tr -d '\r\n' < "${PAT_FILE}")"
if [[ -z "${VSCE_PAT}" ]]; then
	echo "PAT file is empty: ${PAT_FILE}"
	exit 1
fi

"${ROOT_DIR}/tools/sdv_wtrl_render_readmes.sh"

vsce publish -p "${VSCE_PAT}" -i "${VSIX_PATH}"
