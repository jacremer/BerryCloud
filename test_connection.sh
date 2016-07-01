#!/bin/bash

WGET="/usr/bin/wget"
EXITCODE=0

$WGET -q --tries=20 --timeout=10 http://www.google.com -O /tmp/google.idx &> /dev/null
if [ ! -s /tmp/google.idx ]
then
     echo -e "\e[31mNot Connected!"
     EXITCODE=1
else
    echo -e "\e[32mConnected! \o/"
fi

# Reset colors
echo -e "\e[0m"
exit $EXITCODE
