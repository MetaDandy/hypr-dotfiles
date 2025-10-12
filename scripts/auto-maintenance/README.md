# Auto Maintenance

This system performs automatic weekly maintenance on your Linux system using systemd and a bash script.  
Now, the service and timer run at the **system level** for administrative tasks.

## Included files

- `auto-maintenance.sh`: Maintenance script.
- `auto-maintenance.service`: systemd service to run the script.
- `auto-maintenance.timer`: systemd timer to schedule weekly execution.
- `99-grub.hook` (optional): Pacman hook to automatically update GRUB after kernel or GRUB package changes.

## Installation (System Level)

1. **Copy the script and unit files to system locations:**

```bash
sudo cp auto-maintenance.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/auto-maintenance.sh
sudo cp auto-maintenance.service /etc/systemd/system/
sudo cp auto-maintenance.timer /etc/systemd/system/
```

2. **(Optional) Install the GRUB pacman hook:**

If your system does **not** automatically update GRUB after kernel upgrades, copy the hook:

```bash
sudo cp 99-grub.hook /etc/pacman.d/hooks/
```

This hook ensures that after updating or installing the kernel or GRUB, your GRUB configuration is regenerated.

3. **Reload systemd services:**

```bash
sudo systemctl daemon-reload
```

4. **Enable and start the timer:**

```bash
sudo systemctl enable --now auto-maintenance.timer
```

5. **Check that the timer is active:**

```bash
systemctl list-timers
```

## Manual execution

To run the maintenance manually as root:

```bash
sudo /usr/local/bin/auto-maintenance.sh
```

## Notes

- The script only runs on Sundays.
- The service runs as root, so administrative commands work without password prompts.
- Check logs with:

```bash
journalctl -u auto-maintenance.service
```

---

## About the GRUB Hook (`99-grub.hook`)

Some custom or minimal installations may not automatically update GRUB after kernel upgrades.  
If that's your case, you can use the provided `99-grub.hook` file.  
Copy it to `/etc/pacman.d/hooks/` as shown above.  
This is **optional** and only needed if your system does not already handle GRUB updates automatically.
