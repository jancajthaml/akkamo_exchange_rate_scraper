#!/bin/bash  

. common.sh

syncDate="2016-08-16"

if online; then
  #check if syncDate is for today or historic here
  response=$(request "https://www.csob.cz/portal/lide/produkty/kurzovni-listky/kurzovni-listek/-/date/kurzy.txt")

  if [ $? -eq 0 ]; then

    dataDate=$(head -n 1 <<< "$response" | cut -d " " -f 1)

    if [[ "$syncDate" != "$dataDate" ]]; then
      echo "no data for $syncDate"
      exit 1
    fi
      
    while IFS='' read -r LINE || [[ -n "$LINE" ]]; do
      #Země;Množství;Měna;Změna;Nákup;Prodej;Střed;Nákup;Prodej;Střed
      amount=$(cut -d ";" -f 2 <<< $LINE)
      currencyTarget=$(cut -d ";" -f 3 <<< $LINE)
      currencySource="CZK"
      buy=$(cut -d ";" -f 5 <<< $LINE)
      sell=$(cut -d ";" -f 6 <<< $LINE)
      sell=${sell//[,]/.}
      buy=${buy//[,]/.}

      normalizedBuy=$(lua -e "print($sell/$amount)")
      normalizedSell=$(lua -e "print($buy/$amount)")

      echo "1 $currencyTarget = sell: $normalizedSell $currencySource, buy: $normalizedBuy $currencySource"

    done <<< "$(tail -n +5 <<< "$response")"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

