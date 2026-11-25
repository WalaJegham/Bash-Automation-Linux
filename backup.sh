#!/usr/bin/env bash
# backup.sh
# Incremental backup with rsync. The first run copies everything; later runs only
# copy files that changed. Archive mode (-a) preserves timestamps, permissions, etc.
#
# Override the defaults with environment variables, e.g.:
#   SOURCE_DIR=$HOME/Documents BACKUP_DIR=/mnt/backup/Documents ./backup.sh

set -euo pipefail

SOURCE_DIR="${SOURCE_DIR:-$HOME/Documents}"
BACKUP_DIR="${BACKUP_DIR:-/mnt/backup/Documents}"
LOG_FILE="${LOG_FILE:-$HOME/backup.log}"

if ! command -v rsync >/dev/null 2>&1; then
  echo "rsync is not installed. Install it first (e.g. sudo apt install rsync)." >&2
  exit 1
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Source folder not found: $SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$BACKUP_DIR"

echo "[$(date '+%F %T')] Backup started: $SOURCE_DIR -> $BACKUP_DIR" | tee -a "$LOG_FILE"

# Trailing slash on the source copies the folder's contents but not the folder itself.
rsync -a --itemize-changes "$SOURCE_DIR"/ "$BACKUP_DIR"/ >> "$LOG_FILE" 2>&1

echo "[$(date '+%F %T')] Backup finished" | tee -a "$LOG_FILE"
