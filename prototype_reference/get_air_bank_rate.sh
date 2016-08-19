#!/bin/bash

. common.sh

syncDate="2016-8-11"

if online; then
  response=$(request "https://www.airbank.cz/cs/kurzovni-listek/")
  
  if [ $? -eq 0 ]; then
    currencies_table=$(tr -d '\011\012\015' <<< $response | awk -v FS="(<div class='contentAjax'>|</table>)" '{print $2}' | awk -v FS="(<tbody>|</tbody>)" '{print $2}')
    lines=$(pcregrep -o '<tr>.*?<\/tr>' <<< "${currencies_table}" | sed -e ':a' -e 'N' -e '$!ba' | iconv -f ASCII --byte-subst='\x{%02x}')

    while IFS='' read -r row; do
      chunks=$(sed -E -e 's/.*code"><strong\>(.*)\<\/strong>.*amount">([0-9\.,]+).*buy">([0-9\.,-]+)<\/td>.*sell">([0-9\.,-]+)<\/td>.*/\1 \2 \3 \4/' <<< $row)
      IFS=' ' read -r -a args <<< "$chunks"

      currencyTarget=${args[0]}
      currencySource="CZK"

      amount=${args[1]}

      normalizedBuy=$(calculate "${args[3]} / $amount")
      normalizedSell=$(calculate "${args[2]} / $amount")

      echo "1 $currencyTarget = sell: $normalizedSell $currencySource, buy: $normalizedBuy $currencySource"
    done <<< "$lines"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

