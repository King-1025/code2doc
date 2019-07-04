#!/usr/bin/env bash

STATUS="./status"

if [ -e $STATUS ]; then
   exit 0
 fi

date '+%Y-%m-%d %H:%M:%S' > $STATUS
echo "ok!"
