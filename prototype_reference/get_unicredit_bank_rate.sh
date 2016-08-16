#!/bin/bash  

. common.sh

syncDate="2016-08-09"

if online; then
  #check if syncDate is for today or historic here

  cookies=$(getCookie "https://www.unicreditbank.cz/cs/obcane.html")
  response=$(request "https://www.unicreditbank.cz/cs/exchange_rates_xml.exportxml.html" ${cookies})

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

