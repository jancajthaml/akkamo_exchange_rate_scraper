#!/bin/bash

files=$(ls -p | grep -v /)

while IFS='' read -r filename || [[ -n "$filename" ]]; do
  if [[ "$filename" != "$0" && "$filename" != "common.sh" ]]; then
    name=$(cut -d'.' -f1 <<< $filename)
    result=$(sh $filename)
    echo "##### $name #####"
    echo "$result"
  fi
done <<< "$(awk 'NR > 2' <<< "$files")"