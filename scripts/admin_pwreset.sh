#!/bin/sh

# The resetPasswordFor option in sysadminctl will always create a new Keychain

adminUser="$(/usr/bin/osascript -e 'Tell current application to display dialog "Please enter your admin username" default answer "" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:UserIcon.icns" as alias with title "Reset User Password" with text buttons {"Cancel", "Submit Admin"} cancel button 1 default button 2' -e 'text returned of result')"
adminPassword="$(/usr/bin/osascript -e 'Tell current application to display dialog "Please enter the admin password." default answer "" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:UserIcon.icns" as alias with title "Reset User Password" with text buttons {"Cancel", "Submit Password"} cancel button 1 default button 2 with hidden answer' -e 'text returned of result')"
resetUser="$(/usr/bin/osascript -e 'Tell current application to display dialog "Preparing to reset user password...

Please enter the desired username to be reset." default answer "" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:UserIcon.icns" as alias with title "Create New User" with text buttons {"Cancel", "Reset Password"} cancel button 1 default button 2' -e 'text returned of result')"
newPass="$(/usr/bin/osascript -e 'Tell current application to display dialog "Please enter the desired new password." default answer "" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:UserIcon.icns" as alias with title "Reset User Password" with text buttons {"Cancel", "Submit New Password"} cancel button 1 default button 2 with hidden answer' -e 'text returned of result')"

sysadminctl -adminUser $adminUser -adminPassword $adminPassword -resetPasswordFor $resetUser -newPassword $newPass

# Verify the new password

verify="$(dscl /Local/Default -authonly $resetUser $newPass)"

if [ "$verify" == "" ];then
    echo "Password change was successful."
    /usr/bin/osascript -e 'Tell current application to display dialog "Password Change Successful!" with title "Reset Password" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:UserIcon.icns" as alias with text buttons {"Done"} default button 1'
    exit 0
else
    echo "Error: Password change for $resetUser was not successful."
    /usr/bin/osascript -e 'Tell current application to display dialog "Password Change Unsuccessful!" with title "Reset Password" with icon "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:AlertStopIcon.icns" as alias with text buttons {"Done"} cancel button 1 default button 1'
    exit 1
fi
