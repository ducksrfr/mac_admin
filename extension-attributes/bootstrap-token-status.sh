#!/bin/bash

tokenStatus=$(profiles status -type bootstraptoken | awk '{ print $7 }' | sed 1d)

if [ $tokenStatus == "NO" ]; then
    echo "<result>Not escrowed</result>"
elif [ $tokenStatus == "YES" ]; then
    echo "<result>Escrowed</result>"
else
    echo "<result>Unknown status</result>"
fi
