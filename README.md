Automated Pi-hole Updater mit intelligenter E-Mail-Benachrichtigung
Ein robustes und produktionsreifes Bash-Skript zur Automatisierung von Pi-hole-Updates (pihole -up). Es verhindert parallele Ausführungen per Dateisperre (flock), führt lokale Ausführungsprotokolle und versendet intelligente E-Mail-Benachrichtigungen (eine kompakte Statusübersicht bei Erfolg oder den vollständigen Bericht im Fehlerfall).

Funktionen
Sperre gegen parallele Ausführung: Nutzt flock, um zu verhindern, dass sich überlappende Cron-Jobs gegenseitig stören.

Intelligente Benachrichtigungslogik:

Bei Erfolg: Sendet eine kompakte Zusammenfassung mit den Versionsständen der Kernkomponenten (Core, Web Interface, FTL).

Bei Fehler: Sendet den vollständigen Fehlerbericht zur schnellen Analyse.

Bereinigung von Steuerzeichen: Entfernt Terminal-Farbcode-Sequenzen und Wagenrückläufe aus der Ausgabe, um saubere Plain-Text-Logs und -Mails zu garantieren.

Strikte Fehlerbehandlung: Verwendet set -euo pipefail und sichere Dateiberechtigungen (umask 077).

Voraussetzungen
Ein funktionierendes Pi-hole auf einem unterstützten Linux-System (z. B. Raspberry Pi OS).

Root-Rechte (sudo).

Ein konfigurierter Mail Transfer Agent (MTA) oder ein Mail-Utility wie mailutils, bsd-mailx oder msmtp für den E-Mail-Versand.

Installation & Einrichtung
1. Skript erstellen
Speichere das Skript in einem Systemadministrationsverzeichnis, z. B. unter /usr/local/bin/pihole_update.sh:

Bash
sudo nano /usr/local/bin/pihole_update.sh
Füge den Code (siehe Skript-Code unten) ein.

2. Ausführbarkeit sicherstellen
Bash
sudo chmod +x /usr/local/bin/pihole_update.sh
3. E-Mail-Empfänger anpassen
Öffne das Skript und trage deine E-Mail-Adresse bei der Variablen RECIPIENT_EMAIL ein:

Bash
RECIPIENT_EMAIL="deine-email@example.com"
Automatisierung via Cron
Um das Update regelmäßig (z. B. wöchentlich oder monatlich) automatisch auszuführen, richte einen Root-Cron-Job ein.

Öffne die Crontab von root:

Bash
sudo crontab -e
Füge folgenden Eintrag hinzu (führt das Skript z. B. jeden Sonntag um 03:00 Uhr nachts aus):

Code-Snippet
0 3 * * 0 /usr/local/bin/pihole_update.sh >/dev/null 2>&1
(Hinweis: Das Anhängen von >/dev/null 2>&1 verhindert, dass Cron zusätzlich lokale System-Mails an root sendet, da das Skript den E-Mail-Versand eigenständig übernimmt.)
