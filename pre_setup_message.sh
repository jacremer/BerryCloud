#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
IFCONFIG="/sbin/ifconfig"
IP="/sbin/ip"
IFACE=$($IP -o link show | awk '{print $2,$9}' | grep "UP" | cut -d ":" -f 1)
INTERFACES="/etc/network/interfaces"
ADDRESS=$($IP route get 1 | awk '{print $NF;exit}')
NETMASK=$($IFCONFIG $IFACE | grep Mask | sed s/^.*Mask://)
GATEWAY=$($IP route | awk '/default/ { print $3 }')
PUBLIC=$(curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//')
MAC=$(ifconfig | grep HWaddr | awk '{ print $5 }')
echo -e "\e[32m"
echo    "+--------------------------------------------------------------------+"
echo    "| ####################### Tech and Me - 2016 ####################### |"
echo    "| After pressing any key, enter password: owncloud                   |"
echo    "| A pre-setup script will now run, followed by a reboot.             |"
echo    "|                                                                    |"
echo    "|  You will be notified when the pre-setup is finished.              |"
echo    "|  If that is the case, SSH is installed and you will be prompted    |"
echo    "|  With the login options.                                           |"
echo    "|                                                                    |"
echo    "|                                                                    |"
echo    "| After the reboot log back in with ocadmin///owncloud               |"
echo    "| And the script will auto run, instructing you what to do.          |"
echo    "|                                                                    |"
echo    "|  Your LAN IP:        $ADDRESS                                 |"
echo    "|  Your LAN NetMask:   $NETMASK                                 |"
echo    "|  Your LAN Gateway:   $GATEWAY                                   |"
echo    "|  Your MAC Address :  $MAC                             |"
echo    "|  Interface:          $IFACE                                          |"
echo    "|                                                                    |"
echo    "| #################### https://www.techandme.se #################### |"
echo    "+--------------------------------------------------------------------+"
echo
read -p "Press any key to continue..." -n1 -s
echo -e "\e[0m"
echo

exit 0
