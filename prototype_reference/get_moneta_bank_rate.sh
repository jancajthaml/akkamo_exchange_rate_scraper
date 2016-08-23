#!/bin/bash

. common.sh

isInstalled xls2csv || { echo "missing peer dependency xls2csv for excel file handling, install xls2csv ( http://libxls.sourceforge.net/ or brew install catdoc )" >&2; exit 1; }

syncDate="23.8.2016"

if online; then
  
  spoil=$(request "https://www.moneta.cz/kurzovni-listek")

  if [ $? -eq 0 ]; then
    
    instanceId=$(pcregrep -o '"ExchangeRatePortlet_WAR_monetaportletsportlet_INSTANCE_\K([^_"]+)' <<< "$spoil" | head -n 1)

    response=$(download "https://www.moneta.cz/kurzovni-listek?p_p_id=ExchangeRatePortlet_WAR_monetaportletsportlet_INSTANCE_${instanceId}&p_p_lifecycle=2&p_p_state=normal&p_p_mode=view&p_p_resource_id=downloadAction&p_p_cacheability=cacheLevelPage&p_p_col_id=column-1&p_p_col_pos=1&p_p_col_count=3&_ExchangeRatePortlet_WAR_monetaportletsportlet_INSTANCE_${instanceId}_exchangeRateDate=${syncDate}")

    if [ $? -eq 0 ]; then
      data=$(xls2csv $response 2> /dev/null | iconv -f ASCII --byte-subst='\x{%02x}')

      while IFS='' read -r row; do
        IFS=',' read -r -a args <<< "$row"

        currencyTarget="${args[0]}"
        currencySource="CZK"

        amount="${args[1]}"

        normalizedAmount="1"

        #devizy nakup/prodej
        normalizedBuyDeviza=$(calculate "${args[3]} / $amount")
        normalizedSellDeviza=$(calculate "${args[2]} / $amount")

        #valuty nakup/prodej
        buyValuta="${args[5]}"
        sellValuta="${args[6]}"

        if [[ "$buyValuta" == "*" || "$sellValuta" == "*" ]]; then
          echo "$normalizedAmount $currencyTarget >> VIRTUAL_RATE { sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource }, DATE: { $syncDate }"
        else
          normalizedBuyValuta=$(calculate "$buyValuta / $amount")
          normalizedSellValuta=$(calculate "$sellValuta / $amount")

          echo "$normalizedAmount $currencyTarget >> VIRTUAL_RATE { sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource }, CASH_RATE { sell: $normalizedSellValuta $currencySource, buy: $normalizedBuyValuta $currencySource }, DATE: { $syncDate }"
        fi

      done <<< "$(getLinesBetween "$data" 25 8 | tr -d '"')"

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
