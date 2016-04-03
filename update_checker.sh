#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
# note for devs: change version numbers in techandme.se, update.sh and update_checker.sh for this script to work.
# If techandme.sh contains version number below, then a old version is detected and install a newer version
# Check versions
grep -rHln "1.0" /var/scripts/techandme.sh
if [[ $? > 0 ]]
        then
                echo "It seems you have the latest BerryCloud version..."
         else
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "An update is available, download and install now?") ]]
then
echo
echo "Please enter your password below"
echo
sudo wget https://raw.githubusercontent.com/ezraholm50/BerryCloud/master/update.sh -P /var/scripts/
sudo chmod 750 /var/scripts/update.sh
sudo bash /var/scripts/update.sh
else
sleep 1
fi

fi

exit 0
