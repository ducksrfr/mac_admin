#!/bin/bash

# Download Latest Microsoft Office
# Stephen Short, 10/2021

xmlLocation="/private/var/tmp/office-version-output.xml"

curl "https://macadmins.software/latest.xml" >> $xmlLocation

officeVersion=$( cat $xmlLocation | xmllint --xpath '/latest/o365' - | awk -F"[><]" '{print $3}' )
downloadLink=$( cat $xmlLocation | xmllint --xpath '//package/download' - | head -n 1 | awk -F "[><]" '{print $3}')

curl -L --output /private/var/tmp/Microsoft-Office-$officeVersion.pkg "$downloadLink"
sleep 3
installer -pkg /private/var/tmp/Microsoft-Office-$officeVersion.pkg -target /
