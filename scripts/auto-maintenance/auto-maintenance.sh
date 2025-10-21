#!/bin/bash
# --------------------------------------------
# Auto mantenimiento semanal
# --------------------------------------------
set -euo pipefail

LOG_DIR=/var/log/auto-maintenance
MARKER=/var/lib/auto-maintenance/failed
USER_RUN="metadandy"  

mkdir -p "$LOG_DIR"
mkdir -p "$(dirname "$MARKER")"

on_error() {
  local lineno="$1"
  local exit_code="$2"
  local cmd="${BASH_COMMAND:-unknown}"
  local msg="$(date --iso-8601=seconds) ERROR: command '$cmd' failed at line $lineno with exit $exit_code"
  echo "$msg" | tee -a "$LOG_DIR/last-failure.log" | systemd-cat -t auto-maintenance -p err
  touch "$MARKER"
  if command -v notify-send >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ] && [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    notify-send "Auto-maintenance failed" "$cmd (exit $exit_code). See journal: journalctl -u auto-maintenance.service"
  fi
  echo "Auto-maintenance failed. See $LOG_DIR/last-failure.log and journalctl -u auto-maintenance.service" >&2
  echo "To re-run manually: sudo systemctl start auto-maintenance.service  OR  sudo /usr/local/bin/auto-maintenance.sh FORCE=1" >&2
  exit "$exit_code"
}

trap 'ret=$?; on_error $LINENO $ret' ERR

echo "Starting auto-maintenance..."

day=$(date +%u)
if [ "${FORCE:-0}" -ne 1 ]; then
  if [ "$day" -ne 7 ]; then
    echo "Hoy no es domingo. Saliendo..."
    exit 0
  fi
fi

echo "Actualizando sistema..."
sudo pacman -Syu --noconfirm

if command -v yay >/dev/null 2>&1; then
  echo "Actualizando paquetes AUR (run as user)..."
  runuser -l "$USER_RUN" -c 'yay -Syu --noconfirm' || true
fi

if command -v flatpak >/dev/null 2>&1; then
  echo "Actualizando Flatpak..."
  flatpak update -y || true
fi

echo "Limpiando cachés..."
sudo paccache -rk1

if command -v yay >/dev/null 2>&1; then
  runuser -l "$USER_RUN" -c 'yay -Scc --noconfirm' || true
fi

npm cache clean --force >/dev/null 2>&1 || true
yarn cache clean >/dev/null 2>&1 || true
go clean -modcache -cache -testcache >/dev/null 2>&1 || true

rm -rf ~/.npm ~/.cache/npm ~/.cache/yarn 2>/dev/null || true

sudo journalctl --vacuum-time=7d >/dev/null 2>&1 || true
sudo rm -rf /tmp/* 2>/dev/null || true

rm -f "$MARKER" 2>/dev/null || true
echo "$(date --iso-8601=seconds) SUCCESS: maintenance completed" | tee -a "$LOG_DIR/last-success.log" | systemd-cat -t auto-maintenance -p info

echo "Mantenimiento completado."
df -h | grep "/$"