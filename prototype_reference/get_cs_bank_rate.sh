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
    cols=$(tr -dc ',' <<< "$check" | wc -c | sed -e "s/ //g")
    IFS=',' read -r -a args <<< "$check"

    dataDate=${args[1]}

    if [[ ! "$syncDate" == "$dataDate" ]]; then
      echo "no data for $syncDate"
      exit 1
    fi

    data=$(tail -n +3 <<< "$data")
    flat=$(tr -d "\n\r" <<< "$data")
    rows=$(wc -l <<< "$data" | sed -e "s/ //g")

    IFS=',' read -r -a args <<< "$flat"

    for ((row=0;row<$rows;row++)) do
      offset=$(bc -l <<< "$row * $cols")

      currencyTarget=${args[$((offset + 2))]}
      currencySource="CZK"

      amount=${args[$((offset + 1))]}

      normalizedAmount="1"

      #devizy nakup/prodej
      normalizedBuyDeviza=$(calculate "${args[$((offset + 6))]} / $amount")
      normalizedSellDeviza=$(calculate "${args[$((offset + 5))]} / $amount")

      #valuty nakup/prodej
      buyValuta=${args[$((offset + 9))]}
      sellValuta=${args[$((offset + 8))]}

      if [[ "$buyValuta" == "-" || "$sellValuta" == "-" ]]; then
        echo "$normalizedAmount $currencyTarget >> VIRTUAL_RATE { sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource }, DATE: { $syncDate }"
      else
        normalizedBuyValuta=$(calculate "$buyValuta / $amount")
        normalizedSellValuta=$(calculate "$sellValuta / $amount")

        echo "$normalizedAmount $currencyTarget >> VIRTUAL_RATE { sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource }, CASH_RATE { sell: $normalizedSellValuta $currencySource, buy: $normalizedBuyValuta $currencySource }, DATE: { $syncDate }"
      fi
    done

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

