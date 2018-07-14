#!/bin/sh

# Place a macOS 10.13.4 (or later) installer application from the App Store on an external disk
# The Mac must be running 10.13 or later
# This is not a bootable installer, must be run while logged into an admin user account
# In the same /path/to/USB_stick add any additional installer pkgs
# save this as a dot command file, so you can just double-click the file to launch this command like an app from the external USB drive
# Keep the USB disk inserted in the Mac until the install process successfully completes

sudo /path/to/USB_stick/Install\ macOS\ High\ Sierra.app/Contents/Resources/startosinstall --agreetolicense --nointeraction --eraseinstall --installpackage /path/to/USB_stick/installer1.pkg --installpackage /path/to/USB_stick/installer2.pkg --installpackage /path/to/USB_stick/installer3.pkg --newvolumename "Macintosh HD"
