#!/bin/bash

. common.sh

syncDate="9.8.2016"

if online; then

  #devizy
  response=$(requestPOST "https://www.erasvet.cz/informace-k-produktum/kurzovni-listek-meny/stranky/kurz-meny.aspx?p_auth=9ZVszP0k&p_p_id=exchangeRates_WAR_portalfoundation&p_p_lifecycle=1&p_p_state=normal&p_p_mode=view&p_p_col_id=column-main&p_p_col_count=2&action=list --data \"date:${syncDate}\"")

  if [ $? -eq 0 ]; then
    response=$(tr -d '\011\012\015' <<< "$response" | iconv -f ASCII --byte-subst='\x{%02x}')

    lines=$(awk -v FS="(<tbody>|</tbody>)" '{print $2}' <<< "$response" | pcregrep -o '<tr.*?<\/tr>')
    
    while IFS='' read -r row; do      
      chunks=$(tr -d ' ' <<< "$row" | sed -E -e 's/.*<td.*\/>([A-Z]{3})<\/td>.*<td.*>([0-9]+)<\/td>.*<td.*>([0-9,]+)<\/td>.*<td.*>([0-9,]+)<\/td>.*<td.*>([0-9,]+)<\/td>.*<td.*>([0-9,]+)<\/td>.*/\1;\2;\3;\4;\5;\6/')

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

