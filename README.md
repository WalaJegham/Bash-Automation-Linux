# Linux Automations

Three small Bash automations that make your computer work for you, based on the
video *"Introduction to automation"* (Linux + Bash + cron). No frameworks, no AI agents,
just tools already built into Linux.

| Script | What it does | Core tools |
|---|---|---|
| `organize-downloads.sh` | Moves PDFs to `~/Documents` and PNG/JPEG images to `~/Pictures` | `bash`, `mkdir`, `find`, `mv` |
| `backup.sh` | Incremental backup of a folder to another drive | `rsync` |
| `disk-alert.sh` | Warns when disk usage reaches a threshold (default 80%) | `df`, `if` conditionals |
| `crontab.example` | Schedules all three automatically | `cron` |

## Concepts

1. **Bash scripts** are text files of commands that Linux runs one after another.
2. **cron** is the scheduler that runs a command at specific times.
3. **Conditionals** (`if`) let a script make decisions, like warning you when the disk is nearly full.

Combine these three and you can automate almost anything.

## Requirements

- Linux (or macOS/WSL with GNU `df`; the `df --output` flag is GNU-specific)
- `bash` 4+
- `rsync` (`sudo apt install rsync` / `sudo dnf install rsync`)
- `cron` (usually preinstalled; on some distros `sudo apt install cron`)
- Optional: `notify-send` (package `libnotify-bin`) for desktop notifications

## Installation

```bash
git clone https://github.com/WalaJegham/Bash-Automation-Linux.git
cd Bash-Automation-Linux
chmod +x *.sh
```

## 1. Organize the Downloads folder

`organize-downloads.sh` does the following:

- Creates the destination folders if they don't exist (`mkdir -p`).
- Uses `find` to look **only directly inside** Downloads (`-maxdepth 1`) for `*.pdf`, `*.png`, `*.jpg`, `*.jpeg` (case-insensitive).
- Moves them with `mv -n`, so existing files at the destination are **never overwritten**.
- Leaves every other file where it is.

Test it safely on a practice folder first:

```bash
mkdir -p /tmp/practice
touch /tmp/practice/{notes.pdf,shot.png,photo.JPG,archive.zip}

DOWNLOADS_DIR=/tmp/practice DOCS_DIR=/tmp/docs PICS_DIR=/tmp/pics ./organize-downloads.sh
```

Then run it on your real folder:

```bash
./organize-downloads.sh
```

Configuration (environment variables): `DOWNLOADS_DIR`, `DOCS_DIR`, `PICS_DIR`.

## 2. Automated backups with rsync

`backup.sh` copies a folder to a backup location using `rsync -a` (archive mode keeps
timestamps and permissions). The first run copies everything; later runs only copy
files that changed.

```bash
SOURCE_DIR="$HOME/Documents" BACKUP_DIR="/mnt/backup/Documents" ./backup.sh
```

Configuration: `SOURCE_DIR`, `BACKUP_DIR`, `LOG_FILE` (default `~/backup.log`).

> **Tip:** the backup destination should be a separate drive or machine. Backing up to the
> same disk won't protect you from a drive failure. rsync also works over SSH, so
> `BACKUP_DIR` could be adapted to `user@server:/path` (edit the script's `mkdir` step accordingly).

## 3. Disk space alert

`disk-alert.sh` reads the usage percentage from `df`, compares it with a threshold,
and prints either a warning or an OK message. Each result is appended to a log file,
a desktop notification is sent when `notify-send` exists, and the exit code is `1` on
warning, which you can use to chain other actions (such as sending an email).

```bash
./disk-alert.sh                 # check "/" against 80%
THRESHOLD=1 ./disk-alert.sh     # simulate a nearly full disk to see the warning
CHECK_PATH=/home THRESHOLD=90 ./disk-alert.sh
```

Configuration: `THRESHOLD` (default 80), `CHECK_PATH` (default `/`), `LOG_FILE` (default `~/disk-alert.log`).

## Scheduling everything with cron

Open your crontab:

```bash
crontab -e
```

A cron line has five time fields followed by the command:

```
┌──────── minute (0-59)
│ ┌────── hour (0-23)
│ │ ┌──── day of month (1-31)
│ │ │ ┌── month (1-12)
│ │ │ │ ┌ day of week (0-7, Sunday = 0 or 7)
│ │ │ │ │
* * * * *  command
```

`*` means "every possible value". Paste the lines from [`crontab.example`](crontab.example)
and replace the paths:

```cron
# Organize Downloads every day at 09:00
0 9 * * * /home/YOUR_USER/linux-automations/organize-downloads.sh >> /home/YOUR_USER/organize.log 2>&1

# Back up Documents every night at 23:00
0 23 * * * /home/YOUR_USER/linux-automations/backup.sh

# Check disk usage every hour
0 * * * * /home/YOUR_USER/linux-automations/disk-alert.sh
```

Other schedules:

| Schedule | Cron expression |
|---|---|
| Every hour | `0 * * * *` |
| Every Monday at 08:00 | `0 8 * * 1` |
| First day of every month at 00:00 | `0 0 1 * *` |
| Every 15 minutes | `*/15 * * * *` |

Useful commands: `crontab -l` lists your jobs, `crontab -r` removes all of them.

**Notes**

- Always use **absolute paths** in cron. Cron runs with a minimal environment and `~` / `$HOME`-relative assumptions can break.
- The computer must be on at the scheduled time. If it is often off or asleep, look at `anacron` or a systemd timer.
- Desktop notifications from cron may need `DISPLAY` / `DBUS_SESSION_BUS_ADDRESS` set. The log file always works.
- Scripts must be executable (`chmod +x`).

## Extending the idea

The same pattern (script + cron + `if`) can:

- check whether your website is up (`curl -s -o /dev/null -w "%{http_code}"`)
- scrape a page for deals
- send an email or Telegram message when a check fails
- trigger smart-home actions through their APIs

## Project structure

```
.
├── organize-downloads.sh
├── backup.sh
├── disk-alert.sh
├── crontab.example
└── README.md
```

## Credits

Based on the concepts from the video "Introduction to automation" (Linux, Bash, cron, rsync).

## License

MIT, so use it, change it, share it.
