#!/bin/bash

files=$(ls -p | grep -v /)

while IFS='' read -r filename || [[ -n "$filename" ]]; do
  if [[ "$filename" != "$0" && "$filename" != "common.sh" ]]; then
    name=$(cut -d'.' -f1 <<< $filename)
    echo "\n>>>> $name"
    sh $filename
  fi
done <<< "$files"
