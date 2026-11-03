#!/bin/bash

# ============================================================
# Pi-hole Update mit E-Mail-Benachrichtigung
# Erfolg: kurze E-Mail mit Update-Status der Komponenten
# Fehler: vollständige/gekürzte Log-Ausgabe
# ============================================================

set -euo pipefail
umask 077

# --- Konfiguration ---
LOGDIR="/var/log"
LOGFILE="$LOGDIR/pihole_update.log"
LOCKFILE="/run/lock/pihole-update.lock"
RECIPIENT_EMAIL="deine-email@example.com"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export LC_ALL=C

START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
TEMP_LOG=""

# --- Root-Prüfung ---
if [ "$EUID" -ne 0 ]; then
    echo "FEHLER: Skript muss als Root laufen." >&2
    exit 1
fi

# --- Pi-hole prüfen ---
if ! command -v pihole >/dev/null 2>&1; then
    echo "FEHLER: pihole wurde nicht gefunden." >&2
    exit 1
fi

# --- Log-Verzeichnis prüfen ---
if [ ! -d "$LOGDIR" ]; then
    mkdir -p "$LOGDIR"
fi

# --- Sperre gegen parallele Ausführung ---
exec 9>"$LOCKFILE"

if ! flock -n 9; then
    exit 0
fi

# --- Temporäre Dateien ---
TEMP_LOG=$(mktemp /tmp/pihole-update.XXXXXX) || exit 1
trap 'rm -f "$TEMP_LOG"' EXIT

# --- Update ausführen ---
set +e
RAW_OUTPUT=$(pihole -up 2>&1)
STATUS=$?
set -e

END_TIME=$(date '+%Y-%m-%d %H:%M:%S')

# --- Farben und Steuerzeichen entfernen ---
CLEANED_OUTPUT=$(
    printf '%s\n' "$RAW_OUTPUT" |
    sed -E 's/\x1B\[[0-9;]*[[:alpha:]]//g; s/\r//g; s/✓/[OK]/g' )

# --- Kompakt-Übersicht für die Erfolgsmail extrahieren ---
UPDATE_SUMMARY=$(
    printf '%s\n' "$CLEANED_OUTPUT" | grep -E 'Pi-hole Core:|Web Interface:|FTL:' || echo "Keine Details verfügbar."
)

# --- Vollständigen Bericht erstellen ---
{
    echo "============================================================"
    echo "Pi-hole Update-Bericht"
    echo "Start: $START_TIME"
    echo "Ende: $END_TIME"
    echo "============================================================"
    echo

    if [ "$STATUS" -eq 0 ]; then
        echo "Status: ERFOLG"
    else
        echo "Status: FEHLER (Exit-Code: $STATUS)"
    fi

    echo
    echo "Ausgabe von pihole -up:"
    echo "------------------------------------------------------------"
    printf '%s\n' "${CLEANED_OUTPUT:-Keine Ausgabe erhalten.}"
    echo
    echo "============================================================"
} > "$TEMP_LOG"

# --- Bericht lokal speichern ---
if ! cat "$TEMP_LOG" >> "$LOGFILE"; then
    echo "FEHLER: Schreiben der Logdatei fehlgeschlagen." >&2
    exit 1
fi

# --- E-Mail-Benachrichtigung ---
if command -v mail >/dev/null 2>&1; then

    if [ "$STATUS" -eq 0 ]; then
        EMAIL_SUBJECT="[Pi-hole] Update erfolgreich - $END_TIME"
        EMAIL_BODY="Das Pi-hole-Update wurde erfolgreich abgeschlossen.

Start: $START_TIME
Ende: $END_TIME
Status: ERFOLG

--- Update-Status der Komponenten ---
$UPDATE_SUMMARY

------------------------------------------------------------
Das vollständige Protokoll befindet sich auf dem Server unter:
$LOGFILE"
    else
        EMAIL_SUBJECT="[Pi-hole] ACHTUNG: Update fehlgeschlagen - $END_TIME"
        EMAIL_BODY=$(cat "$TEMP_LOG")
    fi

    MAIL_ERR=$(printf '%s\n' "$EMAIL_BODY" | mail -s "$EMAIL_SUBJECT" "$RECIPIENT_EMAIL" 2>&1) || MAIL_FAILED=1

    if [ "${MAIL_FAILED:-0}" -eq 1 ]; then
        echo "[$END_TIME] FEHLER beim Mailversand: $MAIL_ERR" >> "$LOGFILE"
    fi

else
    echo "[$END_TIME] WARNUNG: Kein 'mail'-Befehl im System gefunden." >> "$LOGFILE"
fi

exit "$STATUS"
