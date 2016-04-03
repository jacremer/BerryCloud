# Version 1.2
apt-get update && apt-get upgrade -y && apt-get -f install -y
apt-get install rsyslog systemd module-init-tools -y
dpkg --configure --pending

# Install rpi-update
echo "deb http://archive.raspberrypi.org/debian/ jessie main" > /etc/apt/sources.list
wget "http://archive.raspberrypi.org/debian/raspberrypi.gpg.key"
apt-key add raspberrypi.gpg.key
apt-get update
apt-get install libraspberrypi-bin -y
curl -L --output /usr/bin/rpi-update https://raw.githubusercontent.com/Hexxeh/rpi-update/master/rpi-update && sudo chmod +x /usr/bin/rpi-update
echo "sudo rpi-update" >> /etc/cron.weekly/rpi-update.sh
chmod 755 /etc/cron.weekly/rpi-update.sh
rpi-update
sed -i 's|1.0|1.2|g' /var/scripts/techandme.sh
rm /var/scripts/update.sh
reboot

exit 0
