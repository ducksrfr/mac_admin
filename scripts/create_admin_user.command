#!/bin/bash

# created by Stephen Short, Bazaarvoice
# You cannot run this script as root, because the root user does not have secureToken. You cannot use sudo sysadminctl.
# This requires direct user interaction by the admin when setting up an account.
# If you're using a LoginHook, I recommend saving this script as a dot command file
# You can also use the SignInCommand key in NoMAD
# open path/to/script.command
# Test this in your environment. You might have to run chmod to set the correct permissions
# This script uses the password passthrough option - to avoid hardcoding a plaintext password
# If you choose to hardcode a password, use sysadminctl interactive -addUser AdminUser -fullName "Admin User" -password TypeUserPasswordHere
# The user running this script must be an admin user, and already have secureToken
# If desired, you can add killall Terminal to the end of if/else

if [ -d /Users/AdminUser ] ; then
      exit 0
else
	echo "Creating AdminUser user. Enter the AdminUser account password"
	sysadminctl interactive -addUser AdminUser -fullName "Admin User" -password - -admin -hint TypeHintHere -picture /path/to/picture
	echo "Account creation successful, continuing to additional settings"
	echo "Type the user's first initial and lastname, then press the return key. You will then be prompted for the current user's password to proceed"
	read ComputerName
	sudo scutil --set ComputerName $ComputerName
	sudo scutil --set HostName $ComputerName
	sudo scutil --set LocalHostName $ComputerName
	echo "Setting the ComputerName, Hostname, and LocalHostName"
	echo "Enabling Location Services"
	sleep 1
	sudo defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled -int 1
	sleep 1
	echo "Setting time zone to US Central. You can manually adjust this in the Date & Time section of System Preferences"
	sleep 1
	sudo /usr/sbin/systemsetup -settimezone "America/Chicago"
	echo "Setting auto time zone selection"
	sudo /usr/bin/defaults write /Library/Preferences/com.apple.timezone.auto Active -bool true
	echo "Setting display to sleep after 10 minutes while on battery"
	sudo pmset -b displaysleep 10
	echo "Setting display to sleep after 10 minutes while on AC power"
	sudo systemsetup -setcomputersleep 10
	echo "Script complete, you may safely quit Terminal"
fi
exit 0
