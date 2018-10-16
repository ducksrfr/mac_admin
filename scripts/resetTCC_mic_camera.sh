#!/bin/bash

# This script is helpful for Mojave users that unintentionally deny or disallow camera or microphone access in a chat app like Lifesize, WebEx, Slack, Skype, etc.
# Highly recommended that the user quits the app before running this script
# If this script will be packaged later, or scoped for a specific app, consider adding a killall command to force quit the targeted app.
# Best practice: the user should close System Preferences before running this script. Consider a killall "System Preferences"

# resets the TCC camera approval database
tccutil reset Camera

# resets the TCC microphone approval database
tccutil reset Microphone
