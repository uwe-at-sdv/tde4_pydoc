#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <vsix-file>"
	exit 1
fi

VSIX_PATH="$1"
if [[ ! -f "${VSIX_PATH}" ]]; then
	echo "VSIX file not found: ${VSIX_PATH}"
	exit 1
fi

code --install-extension "${VSIX_PATH}" --force
