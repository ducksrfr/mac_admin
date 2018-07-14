#!/bin/sh

# Stephen Short, Bazaarvoice
# This script uses the password passthrough option "-" so that a plaintext password is not permanently stored
# The resetPasswordFor option is useful if you don't know the original account password
# The interactive argument is required as sysadminctl will not run as root. The current logged in admin password is required.
# You can add killall Terminal to the end if desired if you save this script as a dot command file

sysadminctl interactive -resetPasswordFor AccountNameHere -newPassword -
exit 0
