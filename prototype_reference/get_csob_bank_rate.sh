#!/bin/bash  

. common.sh

syncDate="2016-08-19"

if online; then
  #check if syncDate is for today or historic here
  response=$(request "https://www.csob.cz/portal/lide/produkty/kurzovni-listky/kurzovni-listek/-/date/kurzy.txt")

  if [ $? -eq 0 ]; then
    dataDate=$(head -n 1 <<< "$response" | cut -d " " -f 1)

    if [[ "$syncDate" != "$dataDate" ]]; then
      echo "no data for $syncDate"
      exit 1
    fi
    
    data=$(tail -n +5 <<< "$response" | iconv -f ASCII --byte-subst='\x{%02x}')

    while IFS='' read -r LINE || [[ -n "$LINE" ]]; do      
      IFS=';' read -r -a args <<< "$LINE"

      #Země;Množství;Měna;Změna;Nákup;Prodej;Střed;Nákup;Prodej;Střed
      amount=${args[1]}
      currencyTarget=${args[2]}
      currencySource="CZK"

      normalizedBuy=$(calculate "${args[5]} / $amount")
      normalizedSell=$(calculate "${args[4]} / $amount")

      echo "1 $currencyTarget = sell: $normalizedSell $currencySource, buy: $normalizedBuy $currencySource"
    done <<< "$data"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

