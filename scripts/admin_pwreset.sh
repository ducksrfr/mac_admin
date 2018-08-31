#!/bin/sh

# The resetPasswordFor option will always create a new Keychain for the user

sysadminctl -adminUser AdminUserHere -adminPassword AdminPasswordHere -resetPasswordFor UserToBeReset -newPassword NewPasswordForUser
