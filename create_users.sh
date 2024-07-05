#!/bin/bash

## 1st funnction to be done is confirm whether user has root privileges
if (("$UID != 0"))
then 
    echo "script requires root priviledge"
    exit 1
else
    echo "root privilege"
fi


##check if the file is provided
if [ -z "$1"];
then
    echo "Error: No file was provided"
    echo "use: $0 "
    exit 1
fi

FILENAME=$1
