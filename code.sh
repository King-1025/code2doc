#!/bin/bash -e

#set -x

#rm -rf  /tmp/tmp*

count=20
output=out.docx
rzx=~/RZH/tool/rzx.sh
xml2docx=~/RZH/tool/xml2docx.py

if [ $# -ge 1 ] && [ $# -le 3 ]; then
  project_path=$1
  if [ "$2" != "" ]; then
     count=$2
  fi
  if [ "$3" != "" ]; then
     output=$3
  fi
else
  echo "$(basename $0) <project-path> [count] [output]"
  exit 0
fi

temp=$(mktemp -u)

$rzx -e "$count" -o "$temp" -r -s "" "$project_path"

echo ""

$xml2docx "$temp" "$output"

cp "$output" ~/ftp

rm -rf "$temp"
