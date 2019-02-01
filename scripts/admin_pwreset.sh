#!/bin/sh

# The resetPasswordFor option will always create a new Keychain for the user

adminUser=""
adminPassword=""
resetUser=""
newPass=""

sysadminctl -adminUser $adminUser -adminPassword $adminPassword -resetPasswordFor $resetUser -newPassword $newPass
