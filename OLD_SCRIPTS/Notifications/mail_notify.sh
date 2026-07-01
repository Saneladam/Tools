#!/bin/zsh

MAILDIR="/home/madas/.local/share/mail/romangarciaguill@gmail.com/INBOX/new"
STATE_FILE="/tmp/last_mail_check.txt"

# Sincroniza correo
/usr/bin/mbsync -a

# Si no existe el archivo de estado, lo creamos con la fecha actual y salimos
if [[ ! -f "$STATE_FILE" ]]; then
    date +%s > "$STATE_FILE"
    exit 0
fi

LAST_CHECK=$(cat "$STATE_FILE")
NOW=$(date +%s)

# Busca correos nuevos posteriores al último chequeo
NEW_FILES=$(find "$MAILDIR" -type f -newermt "@$LAST_CHECK")

if [[ -n "$NEW_FILES" ]]; then
    NEW_COUNT=$(echo "$NEW_FILES" | wc -l)
    LATEST=$(echo "$NEW_FILES" | xargs ls -t | head -n 1)

    # Usar formail para extraer el remitente de forma fiable
    if command -v formail >/dev/null 2>&1; then
        SENDER=$(formail -zx From: < "$LATEST")
    else
        # Fallback si no existe formail
        SENDER=$(grep -m1 "^From:" "$LATEST" | sed 's/^From: //')
    fi

    notify-send \
        --urgency=normal \
        --hint=int:transient:1 \
        "📬 New email" \
        "From: $SENDER\n($NEW_COUNT new message(s))"
fi

# Actualiza la fecha del último chequeo
echo "$NOW" > "$STATE_FILE"
