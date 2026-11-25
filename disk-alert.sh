#!/usr/bin/env bash
# disk-alert.sh
# Checks disk usage with df and warns when it reaches the threshold (default 80%).
# Prints a message, appends it to a log file, and sends a desktop notification
# if notify-send is available. Exit code is 1 on warning, 0 when everything is fine.
#
# Examples:
#   ./disk-alert.sh                    # check "/" against 80%
#   THRESHOLD=1 ./disk-alert.sh        # simulate a nearly full disk
#   CHECK_PATH=/home THRESHOLD=90 ./disk-alert.sh

set -euo pipefail

THRESHOLD="${THRESHOLD:-80}"
CHECK_PATH="${CHECK_PATH:-/}"
LOG_FILE="${LOG_FILE:-$HOME/disk-alert.log}"

# df --output=pcent prints a header line and then e.g. " 42%"; strip everything but digits
usage="$(df --output=pcent "$CHECK_PATH" | tail -n 1 | tr -dc '0-9')"

timestamp="$(date '+%F %T')"

if (( usage >= THRESHOLD )); then
  message="[$timestamp] WARNING: disk usage on $CHECK_PATH is ${usage}% (threshold ${THRESHOLD}%)"
  echo "$message" | tee -a "$LOG_FILE"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Disk space warning" "$CHECK_PATH is ${usage}% full" || true
  fi
  exit 1
else
  message="[$timestamp] OK: disk usage on $CHECK_PATH is ${usage}% (threshold ${THRESHOLD}%)"
  echo "$message" | tee -a "$LOG_FILE"
fi
