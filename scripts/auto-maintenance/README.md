# Auto Maintenance

This system performs automatic weekly maintenance using systemd and a bash script.

## Included files

- `auto-maintenance.sh`: Maintenance script.
- `auto-maintenance.service`: systemd service to run the script.
- `auto-maintenance.timer`: systemd timer to schedule weekly execution.

## Installation

1. **Copy the files to your user directory:**

```bash
cp auto-maintenance.sh ~/
mkdir -p ~/.config/systemd/user/
cp auto-maintenance.service ~/.config/systemd/user/
cp auto-maintenance.timer ~/.config/systemd/user/
chmod +x ~/auto-maintenance.sh
```

2. **Reload user systemd services:**

```bash
systemctl --user daemon-reload
```

3. **Enable and start the timer:**

```bash
systemctl --user enable --now auto-maintenance.timer
```

4. **Check that the timer is active:**

```bash
systemctl --user list-timers
```

## Manual execution

To run the maintenance manually:

```bash
bash ~/auto-maintenance.sh
```

## Notes

- The script only runs on Sundays.
- Check logs with:

```bash
journalctl --user -u auto-maintenance.service
```