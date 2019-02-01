#!/bin/sh

currentUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}')

# Get the network password
echo "Prompting ${currentUser} for the Active Directory password."
userNetworkPass="$(/usr/bin/osascript -e 'Tell current application to display dialog "Please enter your network password. 

Your network password signs you into: GlobalProtect, Okta, and email." default answer "" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:BookmarkIcon.icns" as alias with title "Sync FileVault Password" with text buttons {"Cancel", "Submit Password"} cancel button 1 default button 2 with hidden answer' -e 'text returned of result')"
sleep 1

# Verify network password matches the local user password

verify1="$(dscl /Local/Default -authonly $currentUser $userNetworkPass)"

if [ "$verify1" == "" ];then
    echo "Network password for $currentUser is verified."
else
    echo "Error: Network password for $currentUser is not correct."
    /usr/bin/osascript -e 'Tell current application to display dialog "Incorrect Network Password! 

Please return to the Self-Service app to try again." with title "Sync FileVault Password" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertStopIcon.icns" as alias with text buttons {"Done"} cancel button 1 default button 1'
    exit 1
fi

localAdmin=""
apiUser=""
apiPass=""
apiURL=""
xmlString="<?xml version=\"1.0\" encoding=\"UTF-8\"?><computer><extension_attributes><extension_attribute><name>LAPS</name><value>$newPass</value></extension_attribute></extension_attributes></computer>"
udid=$(/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Hardware UUID:/ { print $3 }')
extAttName="\"LAPS\""
LAPS="$(/usr/bin/curl -s -f -u $apiUser:$apiPass -H "Accept: application/xml" $apiURL/JSSResource/computers/udid/$udid/subset/extension_attributes | xpath "//extension_attribute[name=$extAttName]" 2>&1 | awk -F'<value>|</value>' '{print $2}')"

# Check if LAPS value is null

verify2="$(/usr/bin/curl -s -f -u $apiUser:$apiPass -H "Accept: application/xml" $apiURL/JSSResource/computers/udid/$udid/subset/extension_attributes | xpath "//extension_attribute[name=$extAttName]" 2>&1 | awk -F'<value>|</value>' '{print $2}')"

if [ -z "$verify2" ];then
	echo "LAPS value is null."
	/usr/bin/osascript -e 'Tell current application to display dialog "LAPS Password has null value! 

Please contact the Service Desk for assistance." with title "Sync FileVault Password" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertStopIcon.icns" as alias with text buttons {"Done"} cancel button 1 default button 1'
    exit 1
else
	/usr/bin/osascript -e 'display notification "Preparing to reissue..." with title "Revoking Secure Token"'
fi

# Revoke secureToken from user account
sysadminctl -adminUser $localAdmin -adminPassword $LAPS -secureTokenOff $currentUser -password $userNetworkPass && echo "Successfully removed secureToken."
sleep 1

# Add secureToken back to user account
sysadminctl -adminUser $localAdmin -adminPassword $LAPS -secureTokenOn $currentUser -password $userNetworkPass && echo "Successfully reissued secureToken."
sleep 1
/usr/bin/osascript -e 'display notification "Preparing to sync FileVault password..." with title "Secure Token Enabled"'

# Updates preboot with the new password that has been set.
diskutil apfs updatePreboot / && echo "Successfully updated FV preboot."
sleep 3

# secureToken sync complete, advise user to restart Mac
/usr/bin/osascript -e 'Tell current application to display dialog "You must restart your Mac to complete the password sync.

If you are asked to update your Keychain, please enter your old/previous password." with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertCautionIcon.icns" as alias with title "Sync FileVault Password" with text buttons {"Maybe Later", "Restart Now"} cancel button 1 default button 2' -e 'tell app "System Events" to restart'

exit 0
