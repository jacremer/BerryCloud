#!/bin/bash
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Do you want to use a wireless connection?") ]]
then

#mount /dev/mmcblk0p1 /boot
if 		[ -f /boot/wpa_supplicant.conf ];
	then
	  rm /boot/wpa_supplicant.conf
fi
    echo
    echo "Please copy/paste your wifi network or type it (CASE SENSETIVE)";
    echo
    sleep 5
    sudo iwlist wlan0 scan
    sleep 5
while read inputline
do
what="$inputline"
cat <<-WPA > "/boot/wpa_supplicant.conf"
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
ap_scan=1


network={
    ssid="$what"
    psk="wpa-password"
}
mesg n
WPA

if [ -z "${what}" ];
then
echo "No input detected please try again, after this try we will use a wired connection."
bash /var/scripts/eth_wlan.sh
else
sleep 1
fi
done

# Ask for the password
echo "Please type your wifi password (CASE SENSETIVE)";

while read inputline
do
password="$inputline"
sed -i 's|wpa-password|$password|g' > /boot/wpa_supplicant.conf

if [ -z "${password}" ];
then
echo "No input detected please try again, after this try we will use a wired connection."
bash /var/scripts/eth_wlan.sh
else
sleep 1
fi
done

exit 0

else
    sleep 1
fi

exit 0
