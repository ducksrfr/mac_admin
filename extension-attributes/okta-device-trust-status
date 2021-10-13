#!/bin/bash

currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
trustScript="/Users/$currentUser/Library/Okta/okta_device_trust.py"
certInstalled=$( security find-certificate -a -c 'Okta MTLS' -Z -p okta.keychain )


if [[ -e $trustScript ]] && [[ -n $certInstalled ]]; then
	echo "<result>Device Trust Active</result>"
else
	echo "<result>Not Configured</result>"
fi
