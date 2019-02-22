#!/bin/sh

# version 1.1.2
# This script is intended for local user accounts with a password policy not managed by Active Directory, an IdP, or something like NoMAD.
# If you're using a configuration profile to manage the local user password age, the user will never receive proactive password expiration warnings.
# A user might receive an expiration warning at the login screen, but not in an active user session.
#
#
# Users on Mojave will need to have Jamf whitelisted for Accessibility in a PPPC config profile to allow the simulated click of the "Change Password..." button in System Preferences.
# You will also need Jamf whitelisted for AppleEvents to control System Events
# AppleEvents example: https://github.com/rtrouton/privacy_preferences_control_profiles
# Accessibility example in my Github: "Jamf_accessibility.mobileconfig"
#
#
# This script pulls the current logged in user's password age from a Jamf extended attribute titled "Password Age"
# https://github.com/jamf/Current-User-Password-Age
#
#
# The extended attribute gets updated based on your inventory collection frequency.
# Add this script as a recurring check-in policy that executes once per day.
# If you don't use Jamf you can incorporate their script into this one to pull the password age value.
# A user is simply presented with the Change Password dialog in the Users & Groups prefpane. 
# I don't use dscl to change the password, because that causes issues with secureToken in macOS High Sierra and Mojave.
#
# osascript prompts must be run as the current logged in user

currentUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}')
getUID=$(id -u $currentUser)

# Exit if user is a network account
if [[ $getUID -gt 999 ]]; then
  echo "Account is a network user, stopping expiration check."
  exit 1
fi

apiUser=""
apiPass=""
apiURL=""
udid=$(/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Hardware UUID:/ { print $3 }')
extAttName="\"Password Age\""
passwordAge="$(/usr/bin/curl -s -f -u $apiUser:$apiPass -H "Accept: application/xml" $apiURL/JSSResource/computers/udid/$udid/subset/extension_attributes | xpath "//extension_attribute[name=$extAttName]" 2>&1 | awk -F'<value>|</value>' '{print $2}')"


if [ '$passwordAge -le 59' ];then
	echo "The password for $currentUser is outside the warning period."
	exit 1
elif [ $passwordAge == 60 ];then
	echo "The password for $currentUser expires in 30 days."
	sudo -u $currentUser /usr/bin/osascript -e 'Tell current application to display dialog "Your password expires in 30 days!
	
	" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:UserIcon.icns" as alias with title "Password Expiration Warning" with text buttons {"Maybe Later", "Change Password"} cancel button 1 default button 2' -e 'tell application "Finder" to open POSIX file "/System/Library/PreferencePanes/Accounts.prefPane"' -e 'tell application "System Events" to tell process "System Preferences" to delay 1' -e 'tell application "System Events" to tell process "System Preferences" to click button "Change Password…" of tab group 1 of window "Users & Groups"'
elif [ '$passwordAge -ge 61 -a $passwordAge -le 78' ];then
	echo "The password for $currentUser is outside the warning period."
	exit 1
elif [ $passwordAge -ge 79 -a $passwordAge -le 85 ];then
	echo "The password for $currentUser expires soon!"
	sudo -u $currentUser /usr/bin/osascript -e 'Tell current application to display dialog "Your password expires soon!
	
	" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:UserIcon.icns" as alias with title "Password Expiration Warning" with text buttons {"Maybe Later", "Change Password"} cancel button 1 default button 2' -e 'tell application "Finder" to open POSIX file "/System/Library/PreferencePanes/Accounts.prefPane"' -e 'tell application "System Events" to tell process "System Preferences" to delay 1' -e 'tell application "System Events" to tell process "System Preferences" to click button "Change Password…" of tab group 1 of window "Users & Groups"'
elif [ $passwordAge == 86 ];then
	echo "The password for $currentUser expires in 3 days!"
	sudo -u $currentUser /usr/bin/osascript -e 'Tell current application to display dialog "Your password expires in 3 days!
	
	Avoid account lockout issues by changing your password now." with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertCautionIcon.icns" as alias with title "Password Expiration Warning" with text buttons {"Maybe Later", "Change Password"} cancel button 1 default button 2' -e 'tell application "Finder" to open POSIX file "/System/Library/PreferencePanes/Accounts.prefPane"' -e 'tell application "System Events" to tell process "System Preferences" to delay 1' -e 'tell application "System Events" to tell process "System Preferences" to click button "Change Password…" of tab group 1 of window "Users & Groups"'
elif [ $passwordAge == 87 ];then
	echo "The password for $currentUser expires in 2 days!"
	sudo -u $currentUser /usr/bin/osascript -e 'Tell current application to display dialog "Your password expires in 2 days!
	
	Avoid account lockout issues by changing your password now." with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertCautionIcon.icns" as alias with title "Password Expiration Warning" with text buttons {"Maybe Later", "Change Password"} cancel button 1 default button 2' -e 'tell application "Finder" to open POSIX file "/System/Library/PreferencePanes/Accounts.prefPane"' -e 'tell application "System Events" to tell process "System Preferences" to delay 1' -e 'tell application "System Events" to tell process "System Preferences" to click button "Change Password…" of tab group 1 of window "Users & Groups"'
elif [ $passwordAge == 88 ];then
	echo "The password for $currentUser expires in 1 day!"	
	sudo -u $currentUser /usr/bin/osascript -e 'Tell current application to display dialog "Your password expires tomorrow!
	
	Avoid account lockout issues by changing your password now." with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertCautionIcon.icns" as alias with title "Password Expiration Warning" with text buttons {"Maybe Later", "Change Password"} cancel button 1 default button 2' -e 'tell application "Finder" to open POSIX file "/System/Library/PreferencePanes/Accounts.prefPane"' -e 'tell application "System Events" to tell process "System Preferences" to delay 1' -e 'tell application "System Events" to tell process "System Preferences" to click button "Change Password…" of tab group 1 of window "Users & Groups"'
elif [ $passwordAge == 89 ];then
	echo "The password for $currentUser expires today!"	
	sudo -u $currentUser /usr/bin/osascript -e 'Tell current application to display dialog "Your password expires today!
	
	You must change your password at this time." with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertStopIcon.icns" as alias with title "Password Expiration Warning" with text buttons {"Change Password"} default button 1' -e 'tell application "Finder" to open POSIX file "/System/Library/PreferencePanes/Accounts.prefPane"' -e 'tell application "System Events" to tell process "System Preferences" to delay 1' -e 'tell application "System Events" to tell process "System Preferences" to click button "Change Password…" of tab group 1 of window "Users & Groups"'
elif [ $passwordAge -ge 90 ];then
	echo "The password for $currentUser has expired!"	
	sudo -u $currentUser /usr/bin/osascript -e 'Tell current application to display dialog "Your password has expired!
	
	You must reset your password now to unlock your account." with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertStopIcon.icns" as alias with title "Password Expiration Warning" with text buttons {"Change Password"} default button 1' -e 'tell application "Finder" to open POSIX file "/System/Library/PreferencePanes/Accounts.prefPane"' -e 'tell application "System Events" to tell process "System Preferences" to delay 1' -e 'tell application "System Events" to tell process "System Preferences" to click button "Change Password…" of tab group 1 of window "Users & Groups"'
fi

# allow user time to change password before updating inventory to reflect new password age
sleep 90
/usr/local/jamf/bin/jamf recon
exit 0
