#!/bin/bash

. common.sh

syncDate="2016-08-09"

if online; then

  response=$(request "https://www.sberbankcz.cz/Volksbank/Service/GetExchangeRates.aspx?d=${syncDate}")

  if [ $? -eq 0 ]; then

    lines=$(tr -d "\n\r" <<< "$response" | pcregrep -o '<tbody>.*?<\/tbody>' | pcregrep -o "<tr.*?<\/tr>" | sed -e ':a' -e 'N' -e '$!ba' | iconv -f ASCII --byte-subst='\x{%02x}')

    while IFS='' read -r row; do
      line=$(tr -d '\011\012\015 ' <<< "$row")
      chunks=$(sed -E -e 's/.*>(.*)<\/span>.*>(.*)<\/td>.*>(.*)<\/td>.*>(.*)<\/td>.*>(.*)<\/td>.*>(.*)<\/td>.*>(.*)<\/td>.*>(.*)<\/td>.*/\1;\2;\3;\5;\6;\8/' <<< $line)

      IFS=';' read -r -a args <<< "$chunks"

      #currency;amount;devizaBuy;devizaSell;valutaBuy;valutaSell

      currencyTarget="${args[0]}"
      currencySource="CZK"

      amount="${args[1]}"

      normalizedAmount="1"

      #devizy nakup/prodej
      normalizedBuyDeviza=$(calculate "${args[3]} / $amount")
      normalizedSellDeviza=$(calculate "${args[2]} / $amount")

      #valuty nakup/prodej
      buyValuta="${args[4]}"
      sellValuta="${args[5]}"

      if [[ "$buyValuta" == "-" || "$sellValuta" == "-" ]]; then
        echo "$normalizedAmount $currencyTarget >> VIRTUAL_RATE { sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource }, DATE: { $syncDate }"
      else
        normalizedBuyValuta=$(calculate "$buyValuta / $amount")
        normalizedSellValuta=$(calculate "$sellValuta / $amount")

        echo "$normalizedAmount $currencyTarget >> VIRTUAL_RATE { sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource }, CASH_RATE { sell: $normalizedSellValuta $currencySource, buy: $normalizedBuyValuta $currencySource }, DATE: { $syncDate }"
      fi

    done <<< "$lines"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

