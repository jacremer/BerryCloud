##BerryCloud version 1.0.1 stable

## Version 1.0.2
mv /var/scripts/update.sh /var/scripts/update_1.0.1.sh
apt-get update && apt-get upgrade -y && apt-get -f install -y
apt-get install rsyslog systemd module-init-tools
dpkg --configure --pending

# Install rpi-update
sudo curl -L --output /usr/bin/rpi-update https://raw.githubusercontent.com/Hexxeh/rpi-update/master/rpi-update && sudo chmod +x /usr/bin/rpi-update
echo "sudo rpi-update" >> /etc/cron.weekly/rpi-update.sh
chmod 755 /etc/cron.weekly/rpi-update.sh
rpi-update
reboot
