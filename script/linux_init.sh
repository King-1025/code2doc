#!/usr/bin/env bash

ROOT=$(dirname $0)
STATUS="$ROOT/status"
REQU="$ROOT/requirements.txt"

if [ -e $STATUS ]; then
   cat $STATUS
   exit 0
 fi

pip install -r $REQU

date '+%Y-%m-%d %H:%M:%S' | tee $STATUS
echo "init ok!"
