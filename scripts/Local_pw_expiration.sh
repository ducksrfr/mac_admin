#!/bin/sh

# This script is intended for local user accounts with a password policy not managed by Active Directory or another IdP.
# If you're using a configration profile to manage the local user password age, the user will never receive proactive password expiration warnings.
# A user might receive an expiration warning at the login screen, but not proactively in an active user session.
# This script pulls the current logged in user's password age from a Jamf extended attribute titled "Password Age"
# https://github.com/jamf/Current-User-Password-Age
# The extended attribute gets updated based on your inventory collection frequency.
# Add this script as a recurring check-in policy that executes once per day
# If you don't use Jamf you can incorporate their script into this one to pull the password age value.
# A user is simply presented with the option to open the Users & Groups preference pane to change their password. I purposely do not use dscl to change the password, as that can cause issues with secureToken in macOS 10.13+
# Using sysadminctl to reset a password will always creates a new Keychain, and we'd like to avoid that.


currentUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}')
getUID=$(id -u $currentUser)

# Exit if user is a network account
if [[ $getUID -gt 1000 ]]; then
  echo "Account is a network user, stopping expiration check."
  exit 1
fi

apiUser=""
apiPass=""
apiURL=""
xmlString="<?xml version=\"1.0\" encoding=\"UTF-8\"?><computer><extension_attributes><extension_attribute><name>Password Age</name><value>$passwordAge</value></extension_attribute></extension_attributes></computer>"
udid=$(/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Hardware UUID:/ { print $3 }')
extAttName="\"Password Age\""
passwordAge="$(/usr/bin/curl -s -f -u $apiUser:$apiPass -H "Accept: application/xml" $apiURL/JSSResource/computers/udid/$udid/subset/extension_attributes | xpath "//extension_attribute[name=$extAttName]" 2>&1 | awk -F'<value>|</value>' '{print $2}')"


if [ '$passwordAge -le 59' ];then
	echo "The password for $currentUser is outside the warning period."
	exit 1
elif [ $passwordAge == 60 ];then
	echo "Your password expires in 30 days."
	/usr/bin/osascript -e 'Tell current application to display dialog "Your password expires in 30 days!
	
	" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:UserIcon.icns" as alias with title "Password Expiration Warning" with text buttons {"Maybe Later", "Change Password"} cancel button 1 default button 2' -e 'tell application "Finder" to open POSIX file "/System/Library/PreferencePanes/Accounts.prefPane"'
	exit 0
elif [ '$passwordAge -ge 61 -a $passwordAge -le 78' ];then
	echo "The password for $currentUser is outside the warning period."
	exit 1
elif [ $passwordAge -ge 79 -a $passwordAge -le 85 ];then
	echo "The password for $currentUser expires soon!"
	/usr/bin/osascript -e 'Tell current application to display dialog "Your password expires soon!
	
	" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:UserIcon.icns" as alias with title "Password Expiration Warning" with text buttons {"Maybe Later", "Change Password"} cancel button 1 default button 2' -e 'tell application "Finder" to open POSIX file "/System/Library/PreferencePanes/Accounts.prefPane"'
	exit 0
elif [ $passwordAge == 86 ];then
	echo "The password for $currentUser expires in 3 days!"
	/usr/bin/osascript -e 'Tell current application to display dialog "Your password expires in 3 days!
	
	Avoid account lockout issues by changing your password now." with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertCautionIcon.icns" as alias with title "Password Expiration Warning" with text buttons {"Maybe Later", "Change Password"} cancel button 1 default button 2' -e 'tell application "Finder" to open POSIX file "/System/Library/PreferencePanes/Accounts.prefPane"'
	exit 0
elif [ $passwordAge == 87 ];then
	echo "The password for $currentUser expires in 2 days!"
	/usr/bin/osascript -e 'Tell current application to display dialog "Your password expires in 2 days!
	
	Avoid account lockout issues by changing your password now." with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertCautionIcon.icns" as alias with title "Password Expiration Warning" with text buttons {"Maybe Later", "Change Password"} cancel button 1 default button 2' -e 'tell application "Finder" to open POSIX file "/System/Library/PreferencePanes/Accounts.prefPane"'
	exit 0
elif [ $passwordAge == 88 ];then
	echo "The password for $currentUser expires in 1 day!"	
	/usr/bin/osascript -e 'Tell current application to display dialog "Your password expires tomorrow!
	
	Avoid account lockout issues by changing your password now." with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertCautionIcon.icns" as alias with title "Password Expiration Warning" with text buttons {"Maybe Later", "Change Password"} cancel button 1 default button 2' -e 'tell application "Finder" to open POSIX file "/System/Library/PreferencePanes/Accounts.prefPane"'
	exit 0
elif [ $passwordAge == 89 ];then
	echo "The password for $currentUser expires today!"	
	/usr/bin/osascript -e 'Tell current application to display dialog "Your password expires today!
	
	You must change your password at this time." with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertStopIcon.icns" as alias with title "Password Expiration Warning" with text buttons {"Change Password"} default button 1' -e 'tell application "Finder" to open POSIX file "/System/Library/PreferencePanes/Accounts.prefPane"'
	exit 0
elif [ $passwordAge -ge 90 ];then
	echo "The password for $currentUser has expired!"	
	/usr/bin/osascript -e 'Tell current application to display dialog "Your password has expired!
	
	You must reset your password now to unlock your account." with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertStopIcon.icns" as alias with title "Password Expiration Warning" with text buttons {"Change Password"} default button 1' -e 'tell application "Finder" to open POSIX file "/System/Library/PreferencePanes/Accounts.prefPane"'
	exit 0	
fi
