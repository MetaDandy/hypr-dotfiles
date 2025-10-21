# Auto Maintenance

This system performs automatic weekly maintenance on your Linux system using systemd and a bash script.  
The service and timer run at the **system level** and the script now includes failure detection, logging and a manual re-run mechanism.

## Included files

- `auto-maintenance.sh`: Maintenance script (creates logs and failure marker, supports FORCE=1 to bypass Sunday check).
- `auto-maintenance.service`: systemd service to run the script.
- `auto-maintenance.timer`: systemd timer to schedule weekly execution.
- `99-grub.hook` (optional): Pacman hook to automatically update GRUB after kernel or GRUB package changes.

## What changed / new behavior

- Failures are trapped. On error the script:
  - writes an entry to `/var/log/auto-maintenance/last-failure.log`
  - creates a marker file `/var/lib/auto-maintenance/failed`
  - sends a system journal error and (if possible) a desktop notification
  - prints instructions to re-run manually
- On success the script writes `/var/log/auto-maintenance/last-success.log` and removes the failure marker.
- A `FORCE=1` environment variable lets you run the script any day (useful for manual retries).
- `yay` (AUR) is executed as a regular user via `runuser` to avoid running yay as root.
- The script no longer removes `~/go/bin` or `~/go/pkg` to preserve user-installed Go binaries (e.g. Wails).

## Installation (System Level)

1. Copy the script and unit files to system locations:

```bash
sudo cp auto-maintenance.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/auto-maintenance.sh
sudo cp auto-maintenance.service /etc/systemd/system/
sudo cp auto-maintenance.timer /etc/systemd/system/
```

2. (Optional) Install the GRUB pacman hook:

```bash
sudo cp 99-grub.hook /etc/pacman.d/hooks/
```

3. Create log + marker directories (script will create them when run as root, but you can pre-create):

```bash
sudo mkdir -p /var/log/auto-maintenance /var/lib/auto-maintenance
sudo chown root:root /var/log/auto-maintenance /var/lib/auto-maintenance
```

4. Reload systemd and enable timer:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now auto-maintenance.timer
```

5. Verify timer:

```bash
systemctl list-timers
```

## How to check status and failures

- Check journal output:

```bash
journalctl -u auto-maintenance.service
```

- See last failure log (if any):

```bash
sudo cat /var/log/auto-maintenance/last-failure.log
```

- See last success log:

```bash
sudo cat /var/log/auto-maintenance/last-success.log
```

- Check failure marker:

```bash
sudo test -f /var/lib/auto-maintenance/failed && echo "Last run failed" || echo "No failure marker"
```

## How to re-run manually

- Re-run once via systemd (recommended):

```bash
sudo systemctl start auto-maintenance.service
```

- Or run script directly and force execution even if not Sunday:

```bash
sudo FORCE=1 /usr/local/bin/auto-maintenance.sh
```

## Notes and customization

- Edit `USER_RUN` in `auto-maintenance.sh` to match your regular username if different from `metadandy`.
- The `99-grub.hook` is optional — use it only if your installation does not trigger pacman hooks correctly.
