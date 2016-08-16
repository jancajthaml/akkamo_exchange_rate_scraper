#!/bin/bash

. common.sh

syncDate="2016-8-16"

if online; then
  response=$(request "https://www.equabank.cz/dulezite-dokumenty/kurzovni-listek?d=${syncDate}")
  if [ $? -eq 0 ]; then
    currencies_table=$(tr -d '\011\012\015' <<< $response | awk -v FS="(<div id=\"currency\">|</table>)" '{print $2}' | awk -v FS="(<tbody>|</tbody>)" '{print $2}')
    lines=$(pcregrep -o '<tr>.*?<\/tr>' <<< "<frag>${currencies_table}</frag>" | sed -e ':a' -e 'N' -e '$!ba')

    while IFS='' read -r row; do
      sanitized=$(iconv -f ASCII --byte-subst='\x{%02x}' <<< $row)
      chunks=$(sed -E -e 's/.*<span>([A-Z]{3})<\/span>.*cell\-buy"> *([0-9\,]+).*cell-sell"> *([0-9,]+).*/\1 \2 \3/g' -e 's/,/./g' <<< $sanitized)
  
      currencyTarget=$(cut -d " " -f 1 <<< $chunks)
      currencySource="CZK"

      buy=$(cut -d " " -f 2 <<< $chunks | tr -cd '[[:digit:]]._-')
      sell=$(cut -d " " -f 3 <<< $chunks | tr -cd '[[:digit:]]._-')

      echo "1 $currencyTarget = sell: $buy $currencySource, buy: $sell $currencySource"
    done <<< "$lines"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

