#!/bin/bash

seeUpdates=$( cat /Library/Application\ Support/Adobe/OOBE/Configs/ServiceConfig.xml | grep '<visible>' | sed "s@.*<visible>\(.*\)</visible>.*@\1@" )

if [[ $seeUpdates == "false" ]]; then
	sed -i '' 's/<visible>false<\/visible>/<visible>true<\/visible>/g' /Library/Application\ Support/Adobe/OOBE/Configs/ServiceConfig.xml
else
	echo "Value set to true"
fi
