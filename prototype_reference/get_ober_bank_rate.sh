#!/bin/bash

. common.sh

syncDate="22.08.2016"

if online; then

  #devizy
  responseDevizy=$(request "http://www.oberbank.at/OBK_webp/OBK/Application/Rechner/CZ/Fixing/Fixing_cz_export.jsp?dat1=${syncDate}&dat2=${syncDate}&dk=on&fn=on")

  if [ $? -eq 0 ]; then
    
    #valuty
    responseValuty=$(request "http://www.oberbank.at/OBK_webp/OBK/Application/Rechner/CZ/Fixing/Fixing_cz_export.jsp?dat1=${syncDate}&dat2=${syncDate}&nk=on&fn=on")  

    if [ $? -eq 0 ]; then
      
      #druh kurzu;země;měna;nákup;prodej;střed;kurz ze dne
      currencies=()

      while IFS='' read -r row; do
        IFS=';' read -r -a args <<< "$row"

        dataDate="${args[6]}"

        if [[ "$syncDate" == "$dataDate" ]]; then
          currency=${args[1]}
          currencies+=(${currency})

          buy=$(cleanNumber ${args[3]})
          sell=$(cleanNumber ${args[5]})

          hput "${currency}" "${buy} ${sell}"
        fi

      done <<< "$(getLinesBetween "$responseDevizy" 4 3)"

      #####

      while IFS='' read -r row; do
        IFS=';' read -r -a args <<< "$row"

        dataDate="${args[6]}"

        if [[ "$syncDate" == "$dataDate" ]]; then
          currency=${args[1]}
          stash=$(hget ${currency})

          buy=$(cleanNumber ${args[3]})
          sell=$(cleanNumber ${args[5]})

          hput "${currency}" "${stash} ${buy} ${sell}"
        fi

      done <<< "$(getLinesBetween "$responseValuty" 4 3)"

      ####

      if [ ${#currencies[@]} -eq 0 ]; then
        echo "no data for $syncDate"
        exit 1
      fi

      for currency in "${currencies[@]}"; do
        IFS=' ' read -r -a args <<< "$(hget $currency)"

        currencyTarget=${currency}
        currencySource="CZK"

        #devizy nakup/prodej
        normalizedBuyDeviza=${args[1]}
        normalizedSellDeviza=${args[0]}

        #valuty nakup/prodej
        normalizedBuyValuta=${args[3]}
        normalizedSellValuta=${args[2]}

        normalizedAmount="1"

        echo "$normalizedAmount $currencyTarget >> VIRTUAL_RATE { sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource }, DATE: { $syncDate }"
      done

      exit 0
    else
      echo "network unreachable, bailing out"
      exit 1
    fi

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

