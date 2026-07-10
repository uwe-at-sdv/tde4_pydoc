#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="${ROOT_DIR}/templates"
VSCODE_DIR="${ROOT_DIR}/vscode"

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

render_badges() {
	local template_file="$1"
	local output_file="$2"
	local badge_text
	badge_text="$(cat "${template_file}")"
	badge_text="${badge_text//_VERSION_/${VERSION}}"
	printf '%s\n' "${badge_text}" > "${output_file}"
}

render_readme() {
	local template_file="$1"
	local badge_file="$2"
	local output_file="$3"
	local badge_text
	local readme_text

	badge_text="$(cat "${badge_file}")"
	readme_text="$(cat "${template_file}")"
	readme_text="${readme_text//_BADGES_/${badge_text}}"
	printf '%s\n' "${readme_text}" > "${output_file}"
}

tmp_badges_github="$(mktemp)"
tmp_badges_azure="$(mktemp)"
trap 'rm -f "${tmp_badges_github}" "${tmp_badges_azure}"' EXIT

render_badges "${TEMPLATE_DIR}/README_BADGES_GITHUB.template.md" "${tmp_badges_github}"
render_badges "${TEMPLATE_DIR}/README_BADGES_AZURE.template.md" "${tmp_badges_azure}"

render_readme "${TEMPLATE_DIR}/README_GITHUB.template.md" "${tmp_badges_github}" "${ROOT_DIR}/README.md"
render_readme "${TEMPLATE_DIR}/README_AZURE.template.md" "${tmp_badges_azure}" "${VSCODE_DIR}/README.md"

echo "Rendered README.md and vscode/README.md for version ${VERSION}"
