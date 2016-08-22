#!/bin/bash

. common.sh

syncDate="2016-08-22"

if online; then
  response=$(request "http://www.mbank.cz/ajax/currency/getCSV/?id=0&date=${syncDate}&lang=cz")

  if [ $? -eq 0 ]; then
    
    echo "$response"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

