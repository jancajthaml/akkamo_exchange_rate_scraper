#!/bin/bash  

. common.sh

syncDate="22/08/2016"

function indexFor {
  bc -l <<< "$1 + $2 * 15"
}

if online; then
  # 2D array
  response=$(request "http://www.citibank.cz/czech/gcb/personal_banking/data/rates.txt")

  if [ $? -eq 0 ]; then
    flat=$(head -16 <<< $response | tr "\n\r" ",")

    IFS=',' read -r -a data <<< "$flat"

    dataDate=${data[205]}  # 10 + 13 * 15

    if [[ "$syncDate" != "$dataDate" ]]; then
      echo "no data for $syncDate -> \"$dataDate\" != \"$syncDate\""
      exit 1
    fi

    #todo extract following from script
    # var startrownum = 2; // Starting row number
    # var endrownum = 12; // Ending row number

    # var rowsZkr = ["USD","GBP","JPY","CAD","EUR","CHF","HUF","AUD","DKK","PLN","SEK"];
    # var rowsNas = ["1"  ,"1"  ,"100","1"  ,"1"  ,"1" ,"100","1"  ,"1"  ,"1"  ,"1"]; 

    IFS=' ' read -r -a currencies <<< "X X USD GBP JPY CAD EUR CHF HUF AUD DKK PLN SEK"
    IFS=' ' read -r -a amounts <<< "X X 1 1 100 1 1 1 100 1 1 1 1"

    for ((row=2;row<=12;row++)) do
      currencyTarget=${currencies[$row]}
      currencySource="CZK"

      amount=${amounts[$row]}

      #devizy nakup/prodej
      normalizedBuyDeviza=$(calculate "${data[$(indexFor 10 $row)]} / $amount")
      normalizedSellDeviza=$(calculate "${data[$(indexFor 9 $row)]} / $amount")

      #valuty nakup/prodej
      normalizedBuyValuta=$(calculate "${data[$(indexFor 12 $row)]} / $amount")
      normalizedSellValuta=$(calculate "${data[$(indexFor 11 $row)]} / $amount")

      normalizedAmount="1"

      echo "$normalizedAmount $currencyTarget >> VIRTUAL_RATE { sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource }, CASH_RATE { sell: $normalizedSellValuta $currencySource, buy: $normalizedBuyValuta $currencySource }, DATE: { $syncDate }"
    done
    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

