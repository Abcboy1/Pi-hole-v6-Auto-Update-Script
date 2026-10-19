#!/bin/bash

# --- Konfiguration ---
LOGFILE="/var/log/pihole_update.log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

# Wichtig für Cronjobs: Damit System-Befehle sicher gefunden werden
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# E-Mail Konfiguration
RECIPIENT_EMAIL="deine-email@example.com"
EMAIL_SUBJECT="Pi-hole Update Report - $DATE"

# Prüfen, ob als Root ausgeführt
if [ "$EUID" -ne 0 ]; then
    echo "FEHLER: Dieses Skript muss mit Root-Rechten (sudo) ausgeführt werden."
    exit 1
fi

# Temporäre Datei für den sauberen Bericht
TEMP_LOG=$(mktemp)

{
    echo "------------------------------------------------------------"
    echo " [Pi-hole Update] Start: $DATE"
    echo "------------------------------------------------------------"
    
    # Pi-hole Update ausführen, Farbcodes/Steuerzeichen entfernen und Symbole anpassen
    OUTPUT=$(pihole -up 2>&1 | sed 's/\x1b\[[0-9;]*m//g; s/\r//g' | sed 's/\[✓\]/[OK]/g; s/✓/[OK]/g')
    STATUS=$?
    
    # Nur die wichtigen Zeilen filtern und technische Zwischenschritte (dependency package) ausschließen
    echo "$OUTPUT" | grep -E "Checking for updates|Core:|Web Interface:|FTL:|Everything is up to date|Update available|Pi-hole successfully updated|\[OK\]" \
                   | grep -v "dependency package" \
                   | sed 's/^/  /'
    
    echo "------------------------------------------------------------"
    if [ $STATUS -eq 0 ]; then
        echo " Status: ERFOLG"
    else
        echo " Status: FEHLER (Exit-Code: $STATUS)"
    fi
    echo "------------------------------------------------------------"
} > "$TEMP_LOG"

# In die Haupt-Logdatei anhängen
cat "$TEMP_LOG" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# E-Mail versenden (wenn mail installiert ist)
if command -v mail >/dev/null 2>&1; then
    mail -s "$EMAIL_SUBJECT" "$RECIPIENT_EMAIL" < "$TEMP_LOG"
fi

# Aufräumen
rm -f "$TEMP_LOG"
