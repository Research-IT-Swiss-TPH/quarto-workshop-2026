#!/usr/bin/env bash
# find_aptos.sh — Detect whether the Aptos font is available for rendering.
#
# Read-only: this script ONLY looks. It never installs, copies, or edits
# anything, so it is safe to run once the user has agreed to a font scan.
#
# Why this exists: the current (indigo) Swiss TPH LaTeX demos hardcode a
# `mainfontoptions` Path that points at the demo author's personal machine.
# That path must never be copied into a user's document. Instead, detect where
# (or whether) Aptos actually lives on THIS machine and wire the document to
# that — or fall back gracefully.
#
# Output on stdout, exactly one of:
#   REGISTERED                  Aptos is known to the OS font system (fontconfig
#                               via fc-list). xelatex resolves `mainfont: Aptos`
#                               on its own — no Path option needed.
#   DIR<TAB><posix-dir>         Aptos .ttf files found in <posix-dir>. Use this
#                               as the xelatex `Path =` option. A second
#                               WIN<TAB><windows-dir> line may follow when the
#                               directory is a Windows mount (/mnt/c/...), for
#                               renders driven by a Windows Quarto/TeX install.
#   NOTFOUND                    Aptos not found in any scanned location.
#
# Exit codes: 0 = found (REGISTERED or DIR), 3 = NOTFOUND, 2 = usage error.

set -u

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  grep '^#' "$0" | sed 's/^# \{0,1\}//'
  exit 2
fi

# 1) Registered with the OS font system? Cleanest case — no Path option needed.
if command -v fc-list >/dev/null 2>&1; then
  if fc-list 2>/dev/null | grep -qi 'aptos'; then
    echo "REGISTERED"
    exit 0
  fi
fi

# 2) Scan likely font directories for Aptos*.ttf. Covers Linux, macOS, and
#    Windows fonts reachable from WSL via /mnt. Globs that don't match expand
#    to nothing thanks to nullglob.
shopt -s nullglob 2>/dev/null || true

candidates=(
  "$HOME/.fonts"
  "$HOME/.local/share/fonts"
  "$HOME/Library/Fonts"
  "/usr/share/fonts"
  "/usr/local/share/fonts"
  "/Library/Fonts"
  "/System/Library/Fonts"
  "/mnt/c/Windows/Fonts"
)
# Windows per-user font store(s), reachable from WSL.
for d in /mnt/c/Users/*/AppData/Local/Microsoft/Windows/Fonts; do
  candidates+=("$d")
done
# Native Windows (git-bash / MSYS) environment variables, if present.
[ -n "${WINDIR:-}" ]     && candidates+=("$WINDIR/Fonts")
[ -n "${LOCALAPPDATA:-}" ] && candidates+=("$LOCALAPPDATA/Microsoft/Windows/Fonts")

for dir in "${candidates[@]}"; do
  [ -d "$dir" ] || continue
  # -maxdepth keeps the scan shallow and fast; case-insensitive match.
  hit="$(find "$dir" -maxdepth 2 -iname 'aptos*.ttf' 2>/dev/null | head -n1)"
  if [ -n "$hit" ]; then
    found_dir="$(cd "$(dirname "$hit")" && pwd)"
    printf 'DIR\t%s\n' "$found_dir"
    # If this is a Windows mount, also emit the Windows-style path, which is
    # what a Windows-side Quarto/xelatex render expects in the Path option.
    case "$found_dir" in
      /mnt/[a-z]/*)
        drive="$(printf '%s' "$found_dir" | sed -E 's,^/mnt/([a-z])/.*,\1,')"
        rest="$(printf '%s' "$found_dir" | sed -E 's,^/mnt/[a-z]/,,')"
        printf 'WIN\t%s:/%s\n' "$(printf '%s' "$drive" | tr 'a-z' 'A-Z')" "$rest"
        ;;
    esac
    exit 0
  fi
done

echo "NOTFOUND"
exit 3
