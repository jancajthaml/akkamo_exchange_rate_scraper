#!/bin/bash

. common.sh

syncDate="2016-08-09"

if online; then

  #devizy a valuty
  response=$(request "https://www.sberbankcz.cz/Volksbank/Service/GetExchangeRates.aspx?d=${syncDate}")

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

