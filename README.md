# 🛡️ Automated Pi-hole Updater

Ein robustes und produktionsreifes Bash-Skript zur vollautomatischen Aktualisierung von Pi-hole (`pihole -up`). Es verhindert konkurrierende Ausführungen über Dateisperren (`flock`), führt ein persistentes Lokales Protokoll und versendet **intelligente E-Mail-Benachrichtigungen** (eine kompakte Übersicht bei Erfolg oder den vollständigen Bericht im Fehlerfall).

---

## ✨ Funktionen

- **Parallelschutz:** Nutzt `flock`, um das gleichzeitige Starten durch überlappende Cron-Jobs sicher zu verhindern.
- **Intelligente Benachrichtigungen:**
  - **Erfolgsfall:** Sendet eine kompakte Zusammenfassung mit den Versionsständen der Kernkomponenten (`Core`, `Web Interface`, `FTL`).
  - **Fehlerfall:** Sendet den vollständigen Fehler- und Ausführungsbericht zur schnellen Diagnose.
- **Bereinigung:** Entfernt ANSI-Farbcode-Sequenzen und Wagenrückläufe (`\r`), um saubere Plain-Text-Logs und E-Mails zu garantieren.
- **Sicherheit & Robustheit:** Verwendet strikte Fehlerbehandlung (`set -euo pipefail`) und restriktive Dateiberechtigungen (`umask 077`).

---

## 📋 Voraussetzungen

1. Ein funktionierendes **Pi-hole** auf einem unterstützten Linux-System (z. B. Raspberry Pi OS).
2. **Root-Rechte** (`sudo`).
3. Ein funktionierender Mail Transfer Agent (MTA) oder ein Mail-Utility (wie `mailutils`, `bsd-mailx` oder `msmtp`) zum Versenden von System-Mails.

---

## 🚀 Installation & Einrichtung

### 1. Skriptdatei erstellen
Erstelle eine neue Skriptdatei im Verzeichnis `/usr/local/bin/`:

```bash
sudo nano /usr/local/bin/pihole_update.sh
