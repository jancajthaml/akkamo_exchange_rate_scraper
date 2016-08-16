#!/bin/bash

. common.sh

syncDate="2016-8-11"

if online; then
  response=$(request "https://www.airbank.cz/cs/kurzovni-listek/")
  
  if [ $? -eq 0 ]; then
    currencies_table=$(tr -d '\011\012\015' <<< $response | awk -v FS="(<div class='contentAjax'>|</table>)" '{print $2}' | awk -v FS="(<tbody>|</tbody>)" '{print $2}')
    lines=$(pcregrep -o '<tr>.*?<\/tr>' <<< "<frag>${currencies_table}</frag>" | sed -e ':a' -e 'N' -e '$!ba')

    while IFS='' read -r row; do
      sanitized=$(iconv -f ASCII --byte-subst='\x{%02x}' <<< $row)
      chunks=$(sed -E -e 's/.*code"><strong\>(.*)\<\/strong>.*amount">([0-9\.,]+).*buy">([0-9\.,-]+)<\/td>.*sell">([0-9\.,-]+)<\/td>.*/\1 \2 \3 \4/' -e 's/,/./g' <<< $sanitized)

      currencyTarget=$(cut -d " " -f 1 <<< $chunks)
      currencySource="CZK"

      amount=$(cut -d " " -f 2 <<< $chunks)
      buy=$(cut -d " " -f 3 <<< $chunks | tr -cd '[[:digit:]]._-')
      sell=$(cut -d " " -f 4 <<< $chunks | tr -cd '[[:digit:]]._-')

      normalizedBuy=$(lua -e "print($sell/$amount)")
      normalizedSell=$(lua -e "print($buy/$amount)")

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

