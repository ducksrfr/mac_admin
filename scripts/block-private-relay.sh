#!/bin/bash

# Block iCloud Private Relay
# Stephen Short, 10/2021

iCloud=$(cat /private/etc/hosts | grep icloud )
loopbackAddress=$(cat /private/etc/hosts | grep localhost | awk '/[0-9].[0-9]/ {print $1}')


if [[ $iCloud == "" ]]; then
	echo "iCloud Private Relay is not blocked on this device!"
	echo "$loopbackAddress mask.icloud.com" >> /private/etc/hosts
	echo "$loopbackAddress mask-h2.icloud.com" >> /private/etc/hosts
	dscacheutil -flushcache
	killall -HUP mDNSResponder
else
	echo "iCloud Private Relay has already been added to the hosts file."
fi
