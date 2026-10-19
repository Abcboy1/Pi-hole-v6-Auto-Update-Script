# Pi-hole-v6-Auto-Update-Script
Ein kompaktes, sauber strukturiertes Bash-Skript zur automatisierten Aktualisierung von Pi-hole v6 inklusive Gravity-Update, schlanker Log-Dateierstellung und E-Mail-Benachrichtigung.

Features
​🔄 Fokussiert: Aktualisiert ausschließlich Pi-hole (pihole -up), nicht das gesamte Betriebssystem.
​🧹 Saubere Logfiles: Filtert störende ANSI-Farbcodes, Steuerzeichen (^M/\r) und unnötige technische Zwischenschritte (z. B. den Bau von Metapaketen) heraus.
​🔤 Unicode-Fix: Wandelt Konsolen-Symbole ([✓]) zuverlässig in ein universelles [OK] um, um Darstellungsfehler in Log-Dateien und E-Mails zu vermeiden.
​📧 E-Mail-Benachrichtigung: Versendet den kompakten Statusbericht automatisch nach jedem Durchlauf via msmtp / mailutils.
​⏱️ Cronjob-Optimiert: Enthält feste PATH-Variablen, um eine fehlerfreie Ausführung im Hintergrund zu garantieren.
​Beispiel für den Log-Output

Beispiel für den Log-Output
------------------------------------------------------------
 [Pi-hole Update] Start: 2026-10-19 05:00:00
------------------------------------------------------------
    [i] Checking for updates...
    [i] Pi-hole Core:    up to date
    [i] Web Interface:  up to date
    [i] FTL:            up to date
    [OK] Everything is up to date!
------------------------------------------------------------
 Status: ERFOLG
------------------------------------------------------------
Schnellstart & Installation
1. Repository klonen oder Skript herunterladen
Lade das Skript in dein Home-Verzeichnis herunter:
cd ~
git clone pihole-update.sh
cd pihole-update
(Alternativ erstelle die Datei manuell mit nano pihole-update.sh und füge den Skript-Inhalt ein).
2. Skript anpassen
Öffne das Skript, um deine E-Mail-Adresse einzutragen:
nano pihole-update.sh
Passe die folgende Zeile an:
RECIPIENT_EMAIL="deine-email@example.com"
Speichern mit Strg + O, Enter und Beenden mit Strg + X.
3. Ausführungsrechte vergeben
Mache das Skript ausführbar:
chmod +x pihole-update.sh
4. Manuell testen
Führe das Skript einmal mit Root-Rechten aus, um zu prüfen, ob das Log unter /var/log/pihole_update.log korrekt geschrieben wird:
sudo ./pihole-update.sh
Prüfe danach den Inhalt des Logs:
cat /var/log/pihole_update.log
5. Täglichen Cronjob einrichten (Automatisierung)
Da das Skript Root-Rechte für den Befehl pihole -up benötigt, muss der Cronjob in der Root-Crontab eingetragen werden.
Root-Crontab öffnen:
sudo crontab -e
Den folgenden Eintrag am Ende der Datei hinzufügen (Beispiel: Ausführung täglich um 05:00 Uhr morgens):
0 5 * * * /home/pihole-update.sh

Speichern und schließen.
Kurzanleitung: E-Mail-Versand mit msmtp & mailutils
Damit das Skript nach dem Update Statusberichte per E-Mail versenden kann, muss ein SMTP-Relay eingerichtet werden. msmtp ist dafür eine leichte und zuverlässige Lösung.
Schritt 1: Benötigte Pakete installieren
sudo apt update
sudo apt install msmtp msmtp-mTA mailutils -y
Schritt 2: Systemweite Konfiguration erstellen
Erstelle die globale Konfigurationsdatei für msmtp:
sudo nano /etc/msmtprc
Füge folgende Konfiguration ein (Beispiel für SMTP-Versand, passe die Werte an deinen Mailanbieter an):
# Globale Einstellungen
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log

# Konto-Konfiguration
account        default
host           smtp.dein-anbieter.de
port           587
from           deine-absender-email@example.com
user           deine-absender-email@example.com
password       DEIN_GMAIL_ODER_MAIL_PASSWORT
Schritt 3: Rechte der Konfigurationsdatei sichern
Da das Passwort im Klartext in der Datei steht, müssen die Zugriffsrechte eingeschränkt werden:
sudo chmod 600 /etc/msmtprc
sudo chown root:root /etc/msmtprc
Schritt 4: E-Mail-Versand testen
Teste, ob der Versand funktioniert:
echo "Das ist eine Test-E-Mail vom Pi-hole." | mail -s "Test Mail" deine-ziel-email@example.com
Wenn die Test-E-Mail ankommt, ist das System bereit und das Pi-hole-Update-Skript kann ab sofort E-Mails senden!
Voraussetzungen
Pi-hole v6 installiert auf dem System.
Linux-Distribution auf Debian/Raspberry Pi OS Basis.
Root-Rechte zur Ausführung des Skripts.
Lizenz
Dieses Projekt steht unter der MIT-Lizenz – frei zur Nutzung, Anpassung und Weitergabe.
