#!/bin/sh

# Outlook time zone script version 1.0
# Created by Stephen Short, Bazaarvoice

#I run this script as root, or as a custom pkg. You might need to add sudo before some commands
#This script checks if Outlook is running, and if so quits the app.
#Location services are then disabled, and re-enabled.
#Auto time zone selection is disabled, and re-enabled.
#Outlook is then re-opened with the new time zone location.

APP="Outlook"
ERROR="Microsoft Error Reporting"

if ps -ax | grep -v grep | grep $APP
then
	#Closing Microsoft Error Reporting
	pkill $ERROR
	sleep 1
	#Disabling Location Services, please wait 5 seconds
	defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled -int 0
	sleep 5
	#Re-enabling Location Services, please wait 5 seconds
	defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled -int 1
	sleep 5
	#Disabling auto time zone selection
	/usr/bin/defaults write /Library/Preferences/com.apple.timezone.auto Active -bool false
	sleep 1
	#Re-enabling auto time zone selection
	/usr/bin/defaults write /Library/Preferences/com.apple.timezone.auto Active -bool true
	#Opening Microsoft Outlook
	sleep 1
	open /Applications/Microsoft\ Outlook.app
else
	#Disabling Location Services, please wait 5 seconds
	defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled -int 0
	sleep 5
	#Re-enabling Location Services, please wait 5 seconds
	defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled -int 1
	sleep 5
	#Disabling auto time zone selection
	/usr/bin/defaults write /Library/Preferences/com.apple.timezone.auto Active -bool false
	sleep 1
	#Re-enabling auto time zone selection
	/usr/bin/defaults write /Library/Preferences/com.apple.timezone.auto Active -bool true
	#Opening Microsoft Outlook
	sleep 1
	open /Applications/Microsoft\ Outlook.app
fi
exit 0
