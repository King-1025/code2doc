#!/usr/bin/env bash

ROOT=$(dirname $0)
STATUS="$ROOT/status"

if [ -e $STATUS ]; then
   cat $STATUS
   exit 0
 fi

date '+%Y-%m-%d %H:%M:%S' | tee $STATUS
echo "init ok!"
