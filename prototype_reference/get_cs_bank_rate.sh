#!/bin/bash  

. common.sh

syncDate="12.8.2016"

if online; then
  day=$(cut -d "." -f 1 <<< $syncDate)
  month=$(cut -d "." -f 2 <<< $syncDate)
  year=$(cut -d "." -f 3 <<< $syncDate)

  day=${day#0}
  month=${month#0}
  year=${year#0}

  response=$(request "https://www.csas.cz/banka/portlets/exchangerates/current.do?csv=1&times=&event=current&day=${day}&month=${month}&year=${year}")
  
  if [ $? -eq 0 ]; then
    data=$(iconv -f ASCII --byte-subst='\x{%02x}' <<< "$response" | tr -d "\"" | tr -d ' ')

    #"Platnost od:","12.8.2016" ,""," "," ","Devizy"," "," ","Valuty"," "," ","ČNB",
    check=$(head -n 1 <<< "$data")
    IFS=',' read -r -a args <<< "$check"

    dataDate=${args[1]}

    if [[ ! "$syncDate" == "$dataDate" ]]; then
      echo "no data for $syncDate"
      exit 1
    fi

    data=$(tail -n +3 <<< "$data")

    #"Zemì","Jednotka","Mìna","Zmìna [%]", ,"Nákup","Prodej","Støed","Nákup","Prodej","Støed","Støed",
    while IFS='' read -r LINE || [[ -n "$LINE" ]]; do
      IFS=',' read -r -a args <<< "$LINE"

      amount=${args[1]}
      currencyTarget=${args[2]}
      currencySource="CZK"

      normalizedBuy=$(calculate "${args[6]} / $amount")
      normalizedSell=$(calculate "${args[5]} / $amount")

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

