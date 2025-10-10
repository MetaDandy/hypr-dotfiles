#!/bin/bash
# --------------------------------------------
# Auto mantenimiento semanal
# --------------------------------------------

echo "Actualizando sistema..."

day=$(date +%u) 
if [ "$day" -ne 7 ]; then
  echo "Hoy no es domingo. Saliendo..."
  exit 0
fi


sudo pacman -Syu --noconfirm

if command -v yay >/dev/null 2>&1; then
  echo "Actualizando paquetes AUR..."
  yay -Syu --noconfirm
fi

if command -v flatpak >/dev/null 2>&1; then
  echo "Actualizando Flatpak..."
  flatpak update -y
fi

echo "Limpiando cachés..."
sudo paccache -rk1
yay -Scc --noconfirm

npm cache clean --force >/dev/null 2>&1
yarn cache clean >/dev/null 2>&1
go clean -modcache -cache -testcache >/dev/null 2>&1

rm -rf ~/.npm ~/.cache/npm ~/.cache/yarn ~/go/pkg ~/go/bin 2>/dev/null
sudo journalctl --vacuum-time=7d >/dev/null 2>&1
sudo rm -rf /tmp/* 2>/dev/null

echo "Mantenimiento completado."
df -h | grep "/$"
