#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
# MySql
SHUF=$(shuf -i 20-25 -n 1)
MYSQL_PASS=$(cat /dev/urandom | tr -dc "a-zA-Z0-9@#*=" | fold -w $SHUF | head -n 1)
ROOT_PASS=$(cat /dev/urandom | tr -dc "a-zA-Z0-9@#*=" | fold -w $SHUF | head -n 1)
PW_FILE=/var/mysql_password.txt
PW_FILE1=/var/root_password.txt
# ownCloud
CONFIG=$HTML/owncloud/config/config.php
OCVERSION=owncloud-9.0.2.zip
SCRIPTS=/var/scripts
HTML=/var/www
OCPATH=$HTML/owncloud
DATA=$OCPATH/data
# Network
ssl_conf="/etc/apache2/sites-available/owncloud_ssl_domain_self_signed.conf"
IFCONFIG="/sbin/ifconfig"
IP="/sbin/ip"
IFACE=$($IP -o link show | awk '{print $2,$9}' | grep "UP" | cut -d ":" -f 1)
INTERFACES="/etc/network/interfaces"
ADDRESS=$($IP route get 1 | awk '{print $NF;exit}')
NETMASK=$($IFCONFIG $IFACE | grep Mask | sed s/^.*Mask://)
GATEWAY=$($IP route | awk '/default/ { print $3 }')

# Check if root
        if [ "$(whoami)" != "root" ]; then
        echo
        echo -e "\e[31mSorry, you are not root.\n\e[0mYou must type: \e[36msudo \e[0mbash $SCRIPTS/setup.sh"
        echo
        exit 1
fi

# Allow ocadmin to run figlet script
chown ocadmin:ocadmin $SCRIPTS/techandme.sh

clear
echo "+--------------------------------------------------------------------+"
echo "| This script will configure your ownCloud and activate SSL.         |"
echo "| It will also do the following:                                     |"
echo "|                                                                    |"
echo "| - Activate a Virtual Host for your ownCloud install                |"
echo "| - Install Webmin                                                   |"
echo "| - Upgrade your system to latest version                            |"
echo "| - Set secure permissions to ownCloud                               |"
echo "| - Set new passwords to Ubuntu Server and ownCloud                  |"
echo "| - Set new keyboard layout                                          |"
echo "| - Change timezone                                                  |"
echo "| - Set static IP to the system (you have to set the same IP in      |"
echo "|   your router) https://www.techandme.se/open-port-80-443/          |"
echo "|                                                                    |"
echo "|   The script will take about 30 minutes to finish,                 |"
echo "|   depending on your internet connection.                           |"
echo "|                                                                    |"
echo "| ####################### Tech and Me - 2016 ####################### |"
echo "+--------------------------------------------------------------------+"
echo -e "\e[32m"
read -p "Press any key to start the script..." -n1 -s
clear
echo -e "\e[0m"

# Resize sdcard
if 		[ -f /swapfile ];
	then
      		resize2fs /dev/mmcblk0p2
		clear
      	else
           	clear
fi

# Change IP
echo -e "\e[0m"
echo "The script will now configure your IP to be static."
echo -e "\e[36m"
echo -e "\e[1m"
echo "Your internal IP is: $ADDRESS"
echo -e "\e[0m"
echo -e "Write this down, you will need it to set static IP"
echo -e "in your router later. It's included in this guide:"
echo -e "https://www.techandme.se/open-port-80-443/ (step 1 - 5)"
echo -e "\e[32m"
read -p "Press any key to set static IP..." -n1 -s
clear
echo -e "\e[0m"
ifdown $IFACE
sleep 2
ifup $IFACE
sleep 2

cat <<-IPCONFIG > "$INTERFACES"
        auto lo $IFACE
        iface lo inet loopback
        iface $IFACE inet static
                address $ADDRESS
                netmask $NETMASK
                gateway $GATEWAY
# Exit and save:	[CTRL+X] + [Y] + [ENTER]
# Exit without saving:	[CTRL+X]
IPCONFIG

ifdown $IFACE
sleep 2
ifup $IFACE
sleep 2
echo
echo "Testing if network is OK..."
sleep 1
echo
bash /var/scripts/test_connection.sh
sleep 2
echo
echo -e "\e[0mIf the output is \e[32mConnected! \o/\e[0m everything is working."
echo -e "\e[0mIf the output is \e[31mNot Connected!\e[0m you should change\nyour settings manually in the next step."
echo -e "\e[32m"
read -p "Press any key to open /etc/network/interfaces..." -n1 -s
echo -e "\e[0m"
nano /etc/network/interfaces
clear &&
echo "Testing if network is OK..."
ifdown $IFACE
sleep 2
ifup $IFACE
sleep 2
echo
bash /var/scripts/test_connection.sh
sleep 2
clear

# Update
apt-get update && apt-get upgrade -y && apt-get -f install -y

# Show MySQL pass, and write it to a file in case the user fails to write it down
touch $PW_FILE
echo
echo "$MYSQL_PASS" > $PW_FILE
chmod 600 $PW_FILE
echo -e "Your MySQL root password is: \e[32m$MYSQL_PASS\e[0m"
echo "Please save this somewhere safe. The password is also saved in this file: $PW_FILE."
echo "Also please remove it after you wrote it down on a piece of paper, much safer!"
echo "Like this: sudo rm $PW_FILE"
echo -e "\e[32m"
read -p "Press any key to continue..." -n1 -s
echo -e "\e[0m"
sleep 5

# Install MYSQL 5.6
apt-get install software-properties-common -y
echo "mysql-server-5.6 mysql-server/root_password password $MYSQL_PASS" | debconf-set-selections
echo "mysql-server-5.6 mysql-server/root_password_again password $MYSQL_PASS" | debconf-set-selections
apt-get install mysql-server-5.6 -y

# mysql_secure_installation
aptitude -y install expect
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$MYSQL_PASS\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
echo "$SECURE_MYSQL"
aptitude -y purge expect

# Install Apache
#apt-get install apache2 -y
a2enmod rewrite \
        headers \
        env \
        dir \
        mime \
        ssl \
        setenvif

# Set hostname and ServerName
sh -c "echo 'ServerName owncloud' >> /etc/apache2/apache2.conf"
service apache2 restart

# Remove the regular index.html if it exists
if		[ -f $HTML/index.html ];
        then
                rm -f $HTML/index.html
fi

# Test page
wget -q https://raw.githubusercontent.com/enoch85/ownCloud-VM/master/beta/index.php -P $HTML

# Install PHP 7
#echo -ne '\n' | sudo LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php -y
#apt-get update
#apt-get install -y \
#	libapache2-mod-php7.0 \
#        php7.0-common \
#        php7.0-mysql \
#        php7.0-intl \
#        php7.0-mcrypt \
#        php7.0-ldap \
#        php7.0-imap \
#        php7.0-cli \
#        php7.0-gd \
#        php7.0-pgsql \
#        php7.0-json \
#        php7.0-sqlite3 \
#        php7.0-curl  \
#        php7.0-zip  \
#        php7.0-xml \
#        smbclient \
#        libsm6 \
#        libsmbclient

# Download $OCVERSION
wget https://download.owncloud.org/community/$OCVERSION -P $HTML
apt-get install unzip -y
unzip -q $HTML/$OCVERSION -d $HTML
rm $HTML/$OCVERSION

# Create data folder, occ complains otherwise
mkdir $OCPATH/data

# Secure permissions
wget https://raw.githubusercontent.com/ezraholm50/BerryCloud/master/setup_secure_permissions_owncloud.sh -P $SCRIPTS
chmod +x $SCRIPTS/setup_secure_permissions_owncloud.sh
bash $SCRIPTS/setup_secure_permissions_owncloud.sh

# Install ownCloud
sudo -u www-data php $OCPATH/occ maintenance:install --database "mysql" --database-name "owncloud_db" --database-user "root" --database-pass "$MYSQL_PASS" --admin-user "ocadmin" --admin-pass "owncloud"
bash $SCRIPTS/setup_secure_permissions_owncloud.sh

# Setup fail2ban
sudo bash $SCRIPTS/fail2ban.sh

# Show version and status
echo
echo ownCloud version:
sudo -u www-data php $OCPATH/occ status
echo
sleep 3

# Set trusted domain
bash $SCRIPTS/trusted.sh

# Prepare cron.php to be run every 15 minutes
# The user still has to activate it in the settings GUI
crontab -u www-data -l | { cat; echo "*/15  *  *  *  * php -f $OCPATH/cron.php > /dev/null 2>&1"; } | crontab -u www-data -
# Backup cron small workaround, needs fixing
echo "php -f /var/www/owncloud/cron.php > /dev/null 2>&1" >> /etc/cron.daily/owncloud_cron.sh
chmod 755 /etc/cron.daily/owncloud_cron.sh
# Update virus defenitions daily at 03:30
crontab -u root -l | { cat; echo "*30  3  *  *  *  /usr/local/bin/freshclam –quiet"; } | crontab -u root -
# Run secure permissions script daily
cp -ar $SCRIPTS/setup_secure_permissions_owncloud.sh /etc/cron.daily/setup_secure_permissions_owncloud.sh
chmod 755 /etc/cron.daily/setup_secure_permissions_owncloud.sh


# Change values in php.ini (increase max file size)
# max_execution_time
sed -i "s|max_execution_time = 30|max_execution_time = 7000|g" /etc/php/7.0/apache2/php.ini
# max_input_time
sed -i "s|max_input_time = 60|max_input_time = 7000|g" /etc/php/7.0/apache2/php.ini
# memory_limit
sed -i "s|memory_limit = 128M|memory_limit = 512M|g" /etc/php/7.0/apache2/php.ini
# post_max
sed -i "s|post_max_size = 8M|post_max_size = 2200M|g" /etc/php/7.0/apache2/php.ini
# upload_max
sed -i "s|upload_max_filesize = 2M|upload_max_filesize = 2000M|g" /etc/php/7.0/apache2/php.ini

# Generate $ssl_conf
if [ -f $ssl_conf ];
        then
        echo "Virtual Host exists"
else
        touch "$ssl_conf"
        cat << SSL_CREATE > "$ssl_conf"
<VirtualHost *:443>
    Header add Strict-Transport-Security: "max-age=15768000;includeSubdomains"
    SSLEngine on
### YOUR SERVER ADDRESS ###
    ServerAdmin admin@test.com
    ServerName test.com
    ServerAlias test.test.com 
### SETTINGS ###
    DocumentRoot $OCPATH

    <Directory $OCPATH>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
    Satisfy Any 
    </Directory>

    Alias /owncloud "$OCPATH/"

    <IfModule mod_dav.c>
    Dav off
    </IfModule>

    SetEnv HOME $OCPATH
    SetEnv HTTP_HOME $OCPATH
### LOCATION OF CERT FILES ###
    SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
</VirtualHost>
SSL_CREATE
echo "$ssl_conf was successfully created"
sleep 3
fi

# Enable new config
a2ensite owncloud_ssl_domain_self_signed.conf
a2dissite default-ssl
service apache2 restart

# Set config values
# Experimental apps
sudo -u www-data php $OCPATH/occ config:system:set appstore.experimental.enabled --value="true"
# Default mail server (make this user configurable?)
sudo -u www-data php $OCPATH/occ config:system:set mail_smtpmode --value="smtp"
sudo -u www-data php $OCPATH/occ config:system:set mail_smtpauth --value="1"
sudo -u www-data php $OCPATH/occ config:system:set mail_smtpport --value="465"
sudo -u www-data php $OCPATH/occ config:system:set mail_smtphost --value="smtp.gmail.com"
sudo -u www-data php $OCPATH/occ config:system:set mail_smtpauthtype --value="LOGIN"
sudo -u www-data php $OCPATH/occ config:system:set mail_from_address --value="www.techandme.se"
sudo -u www-data php $OCPATH/occ config:system:set mail_domain --value="gmail.com"
sudo -u www-data php $OCPATH/occ config:system:set mail_smtpsecure --value="ssl"
sudo -u www-data php $OCPATH/occ config:system:set mail_smtpname --value="www.en0ch.se@gmail.com"
sudo -u www-data php $OCPATH/occ config:system:set mail_smtppassword --value="techandme_se"

# Download and antivirus
#if [ -d $OCPATH/apps/files_antivirus ]; then
#sleep 1
#else
#wget https://github.com/owncloud/files_antivirus/archive/stable9.zip -P $OCPATH/apps
#cd $OCPATH/apps
#nzip -q stable9.zip
#rm stable9.zip
#mv files_antivirus-stable9/ files_antivirus/
#fi

# Enable antivirus
if [ -d $OCPATH/apps/files_antivirus ]; then
sudo -u www-data php $OCPATH/occ app:enable files_antivirus
fi

# Download and install ocipv6
if [ -d $OCPATH/apps/ocipv6 ]; then
sleep 1
else
wget https://github.com/miska/ocipv6/archive/master.zip -P $OCPATH/apps
cd $OCPATH/apps
unzip -q master.zip
rm master.zip
mv ocipv6-master/ ocipv6/
cd
fi

# Enable ocipv6
if [ -d $OCPATH/apps/ocipv6 ]; then
sudo -u www-data php $OCPATH/occ app:enable ocipv6
fi

# Download and install Documents
if [ -d $OCPATH/apps/documents ]; then
sleep 1
else
wget https://github.com/owncloud/documents/archive/master.zip -P $OCPATH/apps
cd $OCPATH/apps
unzip -q master.zip
rm master.zip
mv documents-master/ documents/
fi

# Enable documents
if [ -d $OCPATH/apps/documents ]; then
sudo -u www-data php $OCPATH/occ app:enable documents
sudo -u www-data php $OCPATH/occ config:system:set preview_libreoffice_path --value="/usr/bin/libreoffice"
fi

# Enable previews
sudo -u www-data php $OCPATH/occ config:system:set enable_previews --value="true"

# Download and install Contacts
#if [ -d $OCPATH/apps/contacts ]; then
#sleep 1
#else
#wget https://github.com/owncloud/contacts/archive/master.zip -P $OCPATH/apps
#unzip -q $OCPATH/apps/master.zip -d $OCPATH/apps
#cd $OCPATH/apps
#rm master.zip
#mv contacts-master/ contacts/
#fi

# Enable Contacts
if [ -d $OCPATH/apps/contacts ]; then
sudo -u www-data php $OCPATH/occ app:enable contacts
fi


# Download and install Logreader
if [ -d $OCPATH/apps/logreader ]; then
sleep 1
else
wget https://github.com/icewind1991/logreader/archive/master.zip -P $OCPATH/apps
unzip -q $OCPATH/apps/master.zip -d $OCPATH/apps
cd $OCPATH/apps
rm master.zip
mv logreader-master/ logreader/
fi

# Enable Logreader
if [ -d $OCPATH/apps/logreader ]; then
sudo -u www-data php $OCPATH/occ app:enable logreader
fi

# Download and install Calendar
if [ -d $OCPATH/apps/calendar ]; then
sleep 1
else
wget https://github.com/owncloud/calendar/archive/master.zip -P $OCPATH/apps
unzip -q $OCPATH/apps/master.zip -d $OCPATH/apps
cd $OCPATH/apps
rm master.zip
mv calendar-master/ calendar/
fi

# Enable Calendar
if [ -d $OCPATH/apps/calendar ]; then
sudo -u www-data php $OCPATH/occ app:enable calendar
fi
cd

# Set secure permissions final (./data/.htaccess has wrong permissions otherwise)
bash $SCRIPTS/setup_secure_permissions_owncloud.sh
clear

# Show ROOT pass, and write it to a file in case the user fails to write it down
#echo
#echo "$ROOT_PASS" > $PW_FILE1
#$ROOT_PASS | sudo passwd
#echo -e "Your ubuntu root password is: \e[32m$ROOT_PASS\e[0m"
#echo "Please save this somewhere safe. The root password is also saved in this file: $PW_FILE1."
#echo "Also please remove it after you wrote it down on a piece of paper, much safer!"
#echo "Like this: sudo rm $PW_FILE1"
#echo -e "\e[32m"
#read -p "Press any key to continue..." -n1 -s
#echo -e "\e[0m"
#sleep 5

# Change password
echo -e "\e[0m"
echo "For better security, change the Linux password for [ocadmin]"
echo "The current password is [owncloud]"
echo -e "\e[32m"
read -p "Press any key to change password for Linux... " -n1 -s
echo -e "\e[0m"
passwd ocadmin
if [[ $? > 0 ]]
then
    passwd ocadmin
else
    sleep 2
fi
echo -e "\e[0m"

echo "For better security, change the ownCloud password for [ocadmin]"
echo "The current password is [owncloud]"
echo -e "\e[32m"
read -p "Press any key to change password for ownCloud... " -n1 -s
echo -e "\e[0m"
sudo -u www-data php $OCPATH/occ user:resetpassword ocadmin
if [[ $? > 0 ]]
then
    sudo -u www-data php $OCPATH/occ user:resetpassword ocadmin
else
    sleep 2
fi

# Redirect http to https
echo "RewriteEngine On" >> $OCPATH/.htaccess
echo "RewriteCond %{HTTPS} off" >> $OCPATH/.htaccess
echo "RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R,L]" >> $OCPATH/.htaccess

clear

# Let's Encrypt
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Do you want to install a real SSL cert (from Let's Encrypt) on this machine?
The scripts are still Beta, feel free to contribute! Make sure port 443 is forwarded to your machine before you start!") ]]
then
	bash $SCRIPTS/activate-ssl.sh
else
	echo
    	echo "OK, but if you want to run it later, just type: sudo bash $SCRIPTS/activate-ssl.sh"
    	echo -e "\e[32m"
    	read -p "Press any key to continue... " -n1 -s
    	echo -e "\e[0m"
fi

# Option to set Dynamic Dns updates
bash $SCRIPTS/dyndns.sh

# Install Redis
bash /var/scripts/install-redis-php-7.sh
sleep 3

# Increase max filesize (expects that changes are made in /etc/php5/apache2/php.ini)
# Here is a guide: https://www.techandme.se/increase-max-file-size/
VALUE="# php_value upload_max_filesize 513M"
if grep -Fxq "$VALUE" $OCPATH/.htaccess
then
        echo "Value correct"
else
        sed -i 's/  php_value upload_max_filesize 513M/# php_value upload_max_filesize 513M/g' $OCPATH/.htaccess
        sed -i 's/  php_value post_max_size 513M/# php_value post_max_size 513M/g' $OCPATH/.htaccess
        sed -i 's/  php_value memory_limit 512M/# php_value memory_limit 512M/g' $OCPATH/.htaccess
fi

# Upgrade system
clear
echo System will now upgrade...
sleep 2
echo
echo
apt-get update
apt-get upgrade -y
apt-get -f install -y
dpkg --configure --pending

# Cleanup 1
apt-get autoremove -y
CLEARBOOT=$(dpkg -l linux-* | awk '/^ii/{ print $2}' | grep -v -e `uname -r | cut -f1,2 -d"-"` | grep -e [0-9] | xargs sudo apt-get -y purge)
echo "$CLEARBOOT"
clear

# Success!
echo -e "\e[32m"
echo    "+--------------------------------------------------------------------+"
echo    "| You have sucessfully installed ownCloud! System will now reboot... |"
echo    "|                                                                    |"
echo -e "| \e[0mLogin to ownCloud in your browser:\e[36m" https://$ADDRESS/owncloud"\e[32m               |"
echo    "|                                                                    |"
echo -e "| \e[0mLogin to Webmin to manage your server:\e[36m" https://$ADDRESS:10000"\e[32m              |"
echo    "|                                                                    |"
echo -e "|    \e[0mPublish your server online! \e[36mhttps://goo.gl/iUGE2U\e[32m               |"
echo    "|                                                                    |"
echo -e "|    \e[91m#################### Tech and Me - 2016 ####################\e[32m    |"
echo    "+--------------------------------------------------------------------+"
echo
read -p "Press any key to reboot..." -n1 -s
echo -e "\e[0m"
echo

# Cleanup 2
sudo -u www-data php $OCPATH/occ maintenance:repair
cp /$OCPATH/apps/ocipv6/ocipv6.sudo /etc/sudoers.d/
chown :www-data /etc/sudoers.d/ocipv6.sudo
apt-get remove --purge expect
rm /var/www/html/index.html
shopt -s extglob
cd /var/scripts
rm !(setup_secure_permissions_owncloud.sh|history.sh|update_checker.sh)
wget -q https://raw.githubusercontent.com/ezraholm50/BerryCloud/master/wan.sh -P /home/ocadmin/
wget -q https://github.com/enoch85/ownCloud-VM/raw/master/lets-encrypt/activate-ssl.sh -P /var/scripts/
wget -q https://raw.githubusercontent.com/ezraholm50/BerryCloud/master/owncloud_update.sh -P /var/scripts/
wget -q https://raw.githubusercontent.com/ezraholm50/BerryCloud/master/techandme.sh -P /var/scripts/
wget -q https://raw.githubusercontent.com/ezraholm50/BerryCloud/master/dyndns.sh -P /var/scripts/
chmod -R +x $SCRIPTS && cd
chmod +x /home/ocadmin/wan.sh
rm $DATA/owncloud.log
cat /dev/null > ~/.bash_history
cat /dev/null > /var/spool/mail/root
cat /dev/null > /var/spool/mail/ocadmin
cat /dev/null > /var/log/apache2/access.log
cat /dev/null > /var/log/apache2/error.log
cat /dev/null > /var/log/cronjobs_success.log
#sed -i "s|mod_php5|mod_php7|g" $OCPATH/.htaccess
sed -i 's|sudo -i||g' /home/ocadmin/.profile
sed -i 's|#bash /var/scripts/pre_setup_message.sh||g' /home/ocadmin/.profile
sed -i 's|bash /var/scripts/instructions.sh|bash /var/scripts/techandme.sh|g' /home/ocadmin/.profile

# Change root .profile
rm /root/.profile
cat <<-ROOT-PROFILE > "/root/.profile"
# ~/.profile: executed by Bourne-compatible login shells.
if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi
if [ -x /var/scripts/history.sh ]; then
        /var/scripts/history.sh
fi
mesg n
ROOT-PROFILE

# Reboot
reboot

exit 0
