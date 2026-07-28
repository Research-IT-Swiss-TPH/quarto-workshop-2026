#!/usr/bin/env bash
# Fetch Swiss TPH Quarto template plumbing from the official repo into a project.
#
# Source of truth:
#   https://github.com/Research-IT-Swiss-TPH/stphtoolbox/tree/main/inst/quarto
#
# Usage:
#   fetch_stph_template.sh <format> [--dest DIR] [--check] [--update]
#                           [--demo] [--no-bibliography]
#
#   <format>   one of: pptx docx report-pdf report-typst letter-pdf letter-typst
#              old-report-pdf old-report-typst old-letter-pdf
#   --dest DIR target working directory (default: current directory)
#   --check    report what is present / missing, download nothing (exit 0 if
#              everything needed is present, exit 3 if something is missing)
#   --update   re-download every needed item even if present (overwrite with latest)
#   --demo     also fetch the current official demo .qmd and demo images
#   --no-bibliography
#              for report formats, skip references.bib
#
# Default behaviour (no --check/--update): download only the items that are missing.
#
# Exit codes: 0 ok, 2 usage/arg error, 3 missing (only with --check), 4 network error.
set -euo pipefail

OWNER="Research-IT-Swiss-TPH"
REPO="stphtoolbox"
BRANCH="main"
SUBDIR="inst/quarto"
RAW="https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}/${SUBDIR}"
TREE_API="https://api.github.com/repos/${OWNER}/${REPO}/git/trees/${BRANCH}?recursive=1"

die() { echo "ERROR: $*" >&2; exit "${2:-2}"; }

# --- args -------------------------------------------------------------------
FORMAT="${1:-}"; shift || true
DEST="."
MODE="install"   # install | check | update
INCLUDE_DEMO=0
INCLUDE_BIBLIOGRAPHY=1
while [ $# -gt 0 ]; do
  case "$1" in
    --dest) DEST="${2:-}"; shift 2 || die "--dest needs a value";;
    --check) MODE="check"; shift;;
    --update) MODE="update"; shift;;
    --demo) INCLUDE_DEMO=1; shift;;
    --no-bibliography) INCLUDE_BIBLIOGRAPHY=0; shift;;
    -h|--help) sed -n '2,20p' "$0"; exit 0;;
    *) die "unknown argument: $1";;
  esac
done
[ -n "$FORMAT" ] || die "missing <format>. One of: pptx docx report-pdf report-typst letter-pdf letter-typst old-report-pdf old-report-typst old-letter-pdf"

# --- format -> needed items -------------------------------------------------
# Each item is either a FILE (relative path under inst/quarto) or a DIR (folder
# whose whole contents must be mirrored). DIRs are expanded via the trees API.
FILES=()       # individual files
DIRS=()        # folders to mirror recursively
DEMO_FILE=""   # official demo qmd for this format
case "$FORMAT" in
  pptx)
    FILES=( "_ppt_metadata.yml" )
    DEMO_FILE="ppt_report_demo.qmd"
    ;;
  docx)
    DIRS=( "_extensions/word-report" )
    DEMO_FILE="word_report_demo.qmd"
    ;;
  report-pdf)
    DIRS=( "_extensions/report" )
    DEMO_FILE="report_simple_demo.qmd"
    [ "$INCLUDE_BIBLIOGRAPHY" -eq 0 ] || FILES+=( "references.bib" )
    ;;
  report-typst)
    DIRS=( "_extensions/report" )
    DEMO_FILE="report_simple_demo_typst.qmd"
    [ "$INCLUDE_BIBLIOGRAPHY" -eq 0 ] || FILES+=( "references.bib" )
    ;;
  letter-pdf)
    DIRS=( "_extensions/letter" )
    DEMO_FILE="letter_demo.qmd"
    ;;
  letter-typst)
    DIRS=( "_extensions/letter" )
    DEMO_FILE="letter_demo_typst.qmd"
    ;;
  old-report-pdf|old-report-typst)
    DIRS=( "_extensions/old-report" )
    [ "$INCLUDE_BIBLIOGRAPHY" -eq 0 ] || FILES+=( "references.bib" )
    ;;
  old-letter-pdf)
    DIRS=( "_extensions/old-letter" )
    ;;
  *) die "unknown format: $FORMAT";;
esac

command -v curl >/dev/null || die "curl is required but not installed"

if [ "$FORMAT" = "pptx" ]; then
  # Keep the PowerPoint template filename in sync with upstream metadata. If the
  # official template changes from ppt_template2.pptx to another file, the skill
  # should not need an edit.
  ppt_metadata="$(curl -fsSL "${RAW}/_ppt_metadata.yml")" || die "failed to read upstream _ppt_metadata.yml" 4
  ppt_reference_doc="$(
    printf '%s\n' "$ppt_metadata" \
      | awk -F: '/^[[:space:]]*reference-doc:[[:space:]]*/ { print $2; exit }' \
      | tr -d "\"'" \
      | sed -E 's/^[[:space:]]+|[[:space:]]+$//g'
  )"
  [ -n "$ppt_reference_doc" ] || die "could not resolve PowerPoint reference-doc from upstream _ppt_metadata.yml" 4
  FILES+=( "$ppt_reference_doc" )
fi

if [ "$INCLUDE_DEMO" -eq 1 ]; then
  [ -n "$DEMO_FILE" ] || die "no official demo file is known for format: $FORMAT"
  FILES+=( "$DEMO_FILE" )
  DIRS+=( "images" )
fi

# Download one repo-relative path (under inst/quarto) into DEST, preserving structure.
download_one() {
  local rel="$1" target
  target="${DEST%/}/${rel}"
  mkdir -p "$(dirname "$target")"
  curl -fsSL "${RAW}/${rel}" -o "$target" || die "failed to download ${rel}" 4
  echo "  fetched  ${rel}"
}

# Expand a folder to its list of file paths (relative to inst/quarto) via the API.
TREE_CACHE=""
list_dir_files() {
  local dir="$1"
  if [ -z "$TREE_CACHE" ]; then
    TREE_CACHE="$(curl -fsSL "$TREE_API")" || die "failed to query GitHub tree API" 4
  fi
  # Paths look like "inst/quarto/_extensions/report/header.tex"; emit only blob
  # paths under the requested dir, stripped to be relative to inst/quarto.
  printf '%s\n' "$TREE_CACHE" \
    | awk -v prefix="${SUBDIR}/${dir}/" -v subdir="${SUBDIR}/" '
        /"path": "/ {
          path = $0
          sub(/^[[:space:]]*"path": "/, "", path)
          sub(/",?[[:space:]]*$/, "", path)
          next
        }
        /"type": "blob"/ {
          if (index(path, prefix) == 1) {
            rel = path
            sub("^" subdir, "", rel)
            print rel
          }
        }
      '
}

present_file() { [ -f "${DEST%/}/$1" ]; }

echo "Swiss TPH templates for format '${FORMAT}' -> ${DEST%/}/  (mode: ${MODE})"

missing=0

handle_file() {
  local f="$1"
  [ -n "$f" ] || return 0
  if present_file "$f"; then
    case "$MODE" in
      check)   echo "  present  $f";;
      update)  download_one "$f";;
      install) echo "  present  $f (kept)";;
    esac
  else
    case "$MODE" in
      check)   echo "  MISSING  $f"; missing=1;;
      *)       download_one "$f";;
    esac
  fi
}

for f in "${FILES[@]:-}"; do
  handle_file "$f"
done

for d in "${DIRS[@]:-}"; do
  [ -n "$d" ] || continue
  echo "  checking upstream folder $d/ ..."
  found=0
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    found=1
    handle_file "$rel"
  done < <(list_dir_files "$d")
  [ "$found" -eq 1 ] || die "upstream folder is empty or missing: $d" 4
done

if [ "$MODE" = "check" ]; then
  if [ "$missing" -eq 0 ]; then echo "All required upstream paths are present."; exit 0
  else echo "Some required files are missing (see MISSING above)."; exit 3; fi
fi
echo "Done."
