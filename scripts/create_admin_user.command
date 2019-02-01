#!/bin/sh

# this script assumes the current logged in user is an admin with secureToken

secureTokenUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}')
secureTokenPassword="$(/usr/bin/osascript -e 'Tell current application to display dialog "Please enter the $secureTokenUser password." default answer "" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:FileVaultIcon.icns" as alias with title "Create New User" with text buttons {"Cancel", "Submit Password"} cancel button 1 default button 2 with hidden answer' -e 'text returned of result')"
fullName="$(/usr/bin/osascript -e 'Tell current application to display dialog "Please enter the the first and last name of the new user.

Example: Maria Johnson" default answer "" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:UserIcon.icns" as alias with title "Create New User" with text buttons {"Cancel", "Submit Full Name"} cancel button 1 default button 2' -e 'text returned of result')"
newUser="$(/usr/bin/osascript -e 'Tell current application to display dialog "Please enter the new account shortname.

Example: mjohnson" default answer "" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:UserIcon.icns" as alias with title "Create New User" with text buttons {"Cancel", "Submit Username"} cancel button 1 default button 2' -e 'text returned of result')"
newPassword="$(/usr/bin/osascript -e 'Tell current application to display dialog "Please enter the new account password." default answer "" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:FileVaultIcon.icns" as alias with title "Create New User" with text buttons {"Cancel", "Submit Password"} cancel button 1 default button 2 with hidden answer' -e 'text returned of result')"
userIcon="/path/to/icon"

# creating the user account
sysadminctl -adminUser $secureTokenUser -adminPassword $secureTokenPassword -addUser $newUser -fullName $fullName -password $newPassword -admin -picture $userIcon && echo "Successfully created new user."
sleep 1
if [ -d /Users/$newUser ] ; then
     /usr/bin/osascript -e 'display notification "Proceeding to name computer..." with title "New User Created"'
else
	echo "User account creation failed."
	exit 1
fi

# Setting the ComputerName, Hostname, and LocalHostName
computerName="$(/usr/bin/osascript -e 'Tell current application to display dialog "Please enter the desired computer name." default answer "" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:com.apple.macbookpro-15-retina-touchid-space-gray.icns" as alias with title "Create New User" with text buttons {"Cancel", "Submit Computer Name"} cancel button 1 default button 2' -e 'text returned of result')"
sleep 1
scutil --set ComputerName $computerName
scutil --set HostName $computerName
scutil --set LocalHostName $computerName
sleep 1
/usr/bin/osascript -e 'display notification "Proceeding to set time zone and location..." with title "Computer Name Set"'

# Enabling Location Services
/usr/bin/defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled -int 1
sleep 1

# Setting time zone to US Central
/usr/sbin/systemsetup -settimezone "America/Chicago"
sleep 1

# Setting auto time zone selection
usr/bin/defaults write /Library/Preferences/com.apple.timezone.auto Active -bool true
sleep 1
/usr/bin/osascript -e 'display notification "Configuring power settings..." with title "Time Zone Set"'

# Setting display to sleep after 10 minutes while on battery"
pmset -b displaysleep 10

# Setting display to sleep after 10 minutes while on AC power
systemsetup -setcomputersleep 10
/usr/bin/osascript -e 'Tell current application to display dialog "User Account Setup Complete!" with title "Create New User" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:HomeFolderIcon.icns" as alias with text buttons {"Done"} default button 1'

exit 0
