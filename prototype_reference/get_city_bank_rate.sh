#!/bin/bash  

. common.sh

syncDate="19/08/2016"

#data=""

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

      #devizy nakup/prodej
      sellDeviza=${data[$(indexFor 9 $row)]}
      buyDeviza=${data[$(indexFor 10 $row)]}

      #valuty nakup/prodej
      #sellValuta=${data[$(indexFor 11 $row)]}
      #buyValuta=${data[$(indexFor 12 $row)]}

      currencyTarget=${currencies[$row]}
      currencySource="CZK"

      amount=${amounts[$row]}

      normalizedBuyDeviza=$(calculate "$buyDeviza / $amount")
      normalizedSellDeviza=$(calculate "$sellDeviza / $amount")

      echo "1 $currencyTarget = sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource"
    done
    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

