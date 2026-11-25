#!/usr/bin/env bash
# organize-downloads.sh
# Moves PDFs from the Downloads folder into Documents, and PNG/JPEG images into Pictures.
# Only touches files directly inside Downloads (no subfolders) and never overwrites
# a file that already exists at the destination.
#
# Override the defaults with environment variables, e.g.:
#   DOWNLOADS_DIR=/tmp/practice DOCS_DIR=/tmp/docs PICS_DIR=/tmp/pics ./organize-downloads.sh

set -euo pipefail

DOWNLOADS_DIR="${DOWNLOADS_DIR:-$HOME/Downloads}"
DOCS_DIR="${DOCS_DIR:-$HOME/Documents}"
PICS_DIR="${PICS_DIR:-$HOME/Pictures}"

if [[ ! -d "$DOWNLOADS_DIR" ]]; then
  echo "Downloads folder not found: $DOWNLOADS_DIR" >&2
  exit 1
fi
mkdir -p "$DOCS_DIR" "$PICS_DIR"

move_matching() {
  local dest="$1"; shift
  local expr=()
  for pattern in "$@"; do
    [[ ${#expr[@]} -gt 0 ]] && expr+=(-o)
    expr+=(-iname "$pattern")
  done

  while IFS= read -r -d '' file; do
    name="$(basename "$file")"
    # Never overwrite an existing file at the destination. Skip it instead.
    # (checked explicitly because newer `mv -n` exits non-zero when it skips)
    if [[ -e "$dest/$name" ]]; then
      echo "Skipped (already exists): $name"
      continue
    fi
    mv -n -- "$file" "$dest"/
    echo "Moved: $name -> $dest"
  done < <(find "$DOWNLOADS_DIR" -maxdepth 1 -type f \( "${expr[@]}" \) -print0)
}

move_matching "$DOCS_DIR" "*.pdf"
move_matching "$PICS_DIR" "*.png" "*.jpg" "*.jpeg"

echo "Done organizing $DOWNLOADS_DIR"
