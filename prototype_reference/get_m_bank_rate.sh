#!/bin/bash

. common.sh

syncDate="2016-08-23"

if online; then
  response=$(request "http://www.mbank.cz/ajax/currency/getCSV/?id=0&date=${syncDate}")

  if [ $? -eq 0 ]; then

    IFS=';' read -r -a args <<< "$(head -n 1 <<< "$response")"
    
    dataDate=$(cut -d " " -f 1 <<< ${args[1]})

    if [[ "$syncDate" != "$dataDate" ]]; then
      echo "no data for $syncDate -> \"$dataDate\" != \"$syncDate\""
      exit 1
    fi

    #Stát;Kód;Měna;Množství;Nákup;Kurz Prodej;Střed;Spread
    while IFS='' read -r row; do
      IFS=';' read -r -a args <<< "$row"

      currencyTarget=${args[1]}
      currencySource="CZK"

      amount=${args[3]}

      normalizedBuyDeviza=$(calculate "${args[5]} / $amount")
      normalizedSellDeviza=$(calculate "${args[6]} / $amount")

      normalizedAmount="1"

      echo "$normalizedAmount $currencyTarget >> VIRTUAL_RATE { sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource }, DATE: { $syncDate }"
    done <<< "$(getLinesBetween "$response" 3 0)"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

