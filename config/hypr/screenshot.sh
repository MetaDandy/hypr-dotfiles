#!/bin/bash

# Directorio para screenshots
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

# Nombre del archivo
FILENAME="$DIR/$(date +'%Y%m%d_%H%M%S').png"

# Tomar screenshot del área seleccionada
grim -g "$(slurp)" "$FILENAME"

if [ -f "$FILENAME" ]; then
    # Copiar al clipboard
    wl-copy < "$FILENAME"
    
    # Mostrar notificación
    notify-send "Screenshot" "Guardado y copiado al clipboard" -i "$FILENAME"
    
    # Mostrar preview (opcional)
    imv "$FILENAME" &
    
    echo "Screenshot guardado en: $FILENAME"
else
    notify-send "Error" "No se pudo tomar el screenshot"
fi
