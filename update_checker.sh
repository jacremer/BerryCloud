#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
# Check if update is available
#function ask_yes_or_no() {
#    read -p "$1 ([y]es or [N]o): "
#    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
#        y|yes) echo "yes" ;;
#        *)     echo "no" ;;
#    esac
#}
#if [[ "yes" == $(ask_yes_or_no "An update is available, download and install now?") ]]
#then
#echo
#echo "Please enter your password below"
#echo
#sudo -i
#wget https://raw.githubusercontent.com/ezraholm50/BerryCloud/master/update.sh
#chmod 750 /var/scripts/update.sh
#bash /var/scripts/update.sh
#else
#sleep 1
#fi
#
#exit 0
#
