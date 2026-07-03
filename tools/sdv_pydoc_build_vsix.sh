#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VSCODE_DIR="${ROOT_DIR}/vscode"

"${ROOT_DIR}/tools/sdv_pydoc_render_readmes.sh"

cd "${VSCODE_DIR}"

if ! command -v vsce >/dev/null 2>&1; then
	echo "vsce not found on PATH"
	exit 1
fi

if ! command -v node >/dev/null 2>&1; then
	echo "node not found on PATH"
	exit 1
fi

VERSION="$(node -p "require('./package.json').version")"
VSIX_NAME="tde4-pydoc-${VERSION}.vsix"

VERSION_REGEX=${VERSION//'.'/'\.'}

# Don't forget to update CHANGELOG.
if [[ -z "$(egrep "\- ${VERSION_REGEX}\s\[[0-9]{4}\-[0-9]{2}\-[0-9]{2}\]:" CHANGELOG)" ]]; then
	echo "version not mentioned in CHANGELOG"
	exit 1
fi

echo "Building ${VSIX_NAME}"
vsce package --no-dependencies --out "${VSIX_NAME}"
echo "Wrote ${VSCODE_DIR}/${VSIX_NAME}"
