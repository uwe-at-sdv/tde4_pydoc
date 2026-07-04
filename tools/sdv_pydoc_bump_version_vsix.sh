#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VSCODE_DIR="${ROOT_DIR}/vscode"
PACKAGE_JSON="${VSCODE_DIR}/package.json"
CHANGELOG="${VSCODE_DIR}/CHANGELOG"
MARKER='#----- extend here --------------------------------------------#'

usage() {
	echo "usage: $(basename "${BASH_SOURCE[0]}") <level>"
	echo "  level: major | minor | patch"
}

LEVEL="${1:-}"
case "${LEVEL}" in
	major|minor|patch) ;;
	-h|--help) usage; exit 0 ;;
	"") echo "error: missing 'level' argument"; usage; exit 1 ;;
	*) echo "error: invalid level '${LEVEL}'"; usage; exit 1 ;;
esac

if ! command -v jq >/dev/null 2>&1; then
	echo "jq not found on PATH"
	exit 1
fi

if [[ ! -f "${PACKAGE_JSON}" ]]; then
	echo "package.json not found: ${PACKAGE_JSON}"
	exit 1
fi

if [[ ! -f "${CHANGELOG}" ]]; then
	echo "CHANGELOG not found: ${CHANGELOG}"
	exit 1
fi

if ! grep -qF "${MARKER}" "${CHANGELOG}"; then
	echo "marker not found in ${CHANGELOG}:"
	echo "  ${MARKER}"
	exit 1
fi

OLD_VERSION="$(jq -r .version "${PACKAGE_JSON}")"
if [[ -z "${OLD_VERSION}" || "${OLD_VERSION}" == "null" ]]; then
	echo "could not read version from ${PACKAGE_JSON}"
	exit 1
fi

if [[ ! "${OLD_VERSION}" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
	echo "version '${OLD_VERSION}' is not in MAJOR.MINOR.PATCH form"
	exit 1
fi

MAJOR="${BASH_REMATCH[1]}"
MINOR="${BASH_REMATCH[2]}"
PATCH="${BASH_REMATCH[3]}"

case "${LEVEL}" in
	major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
	minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
	patch) PATCH=$((PATCH + 1)) ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"

echo "bumping ${LEVEL}: ${OLD_VERSION} -> ${NEW_VERSION}"

printf 'Changelog comment for %s: ' "${NEW_VERSION}"
IFS= read -r COMMENT
if [[ -z "${COMMENT}" ]]; then
	echo "error: empty changelog comment, aborting"
	exit 1
fi

DATE="$(date +%F)"

# Update the version in package.json (jq default 2-space indent matches the file).
tmp_json="$(mktemp)"
trap 'rm -f "${tmp_json}"' EXIT
jq --arg v "${NEW_VERSION}" '.version = $v' "${PACKAGE_JSON}" > "${tmp_json}"
cat "${tmp_json}" > "${PACKAGE_JSON}"

# Insert the new entry directly below the marker line, newest on top.
export MARKER NEW_VERSION DATE COMMENT
tmp_log="$(mktemp)"
trap 'rm -f "${tmp_json}" "${tmp_log}"' EXIT
awk '
	{ print }
	$0 == ENVIRON["MARKER"] {
		printf "- %s [%s]:\n\t%s\n", ENVIRON["NEW_VERSION"], ENVIRON["DATE"], ENVIRON["COMMENT"]
	}
' "${CHANGELOG}" > "${tmp_log}"
cat "${tmp_log}" > "${CHANGELOG}"

echo "updated ${PACKAGE_JSON} to version ${NEW_VERSION}"
echo "added changelog entry under the marker in ${CHANGELOG}"
