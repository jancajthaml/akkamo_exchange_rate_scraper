#!/bin/bash  

. common.sh

syncDate="12.08.2016"

if online; then
  response=$(request "http://www.ingbank.cz/o-ing-bank/kurzovni-listek/?date=${syncDate}")
  if [ $? -eq 0 ]; then
    currencies_table=$(tr -d '\011\012\015' <<< $response | awk -v FS="(<table class='tableBasic' cellSpacing='0' cellPadding='0' border='0' summary=''>|</table>)" '{print $2}' | awk -v FS="(<tbody>|</tbody>)" '{print $2}')
    lines=$(pcregrep -o '<tr.*?<\/tr>' <<< "<frag>${currencies_table}</frag>" | sed -e ':a' -e 'N' -e '$!ba')

    while IFS='' read -r row; do
      sanitized=$(iconv -f ASCII --byte-subst='\x{%02x}' <<< $row)
      chunks=$(sed -E -e 's/.*<b>(.*)<\/b><\/td> <td class="right"> ([0-9,]+).*"> ([0-9,]+).*/\1 \2 \3/' -e 's/,/./g' <<< $sanitized)
  
      currency=$(cut -d " " -f 1 <<< $chunks)
      currencySource=$(cut -d "/" -f 1 <<< $currency)
      currencyTarget=$(cut -d "/" -f 2 <<< $currency)

      buy=$(cut -d " " -f 2 <<< $chunks | tr -cd '[[:digit:]]._-')
      sell=$(cut -d " " -f 3 <<< $chunks | tr -cd '[[:digit:]]._-')

      echo "1 $currencyTarget = sell: $buy $currencySource, buy: $sell $currencySource"
    done <<< "$(tail -n +3 <<< "$lines")"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

