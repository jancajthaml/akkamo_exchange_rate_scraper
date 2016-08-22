#!/bin/bash  

. common.sh

syncDate="12.08.2016"

if online; then
  response=$(request "http://www.ingbank.cz/o-ing-bank/kurzovni-listek/?date=${syncDate}")
  if [ $? -eq 0 ]; then
    currencies_table=$(tr -d '\011\012\015' <<< $response | awk -v FS="(<table class='tableBasic' cellSpacing='0' cellPadding='0' border='0' summary=''>|</table>)" '{print $2}' | awk -v FS="(<tbody>|</tbody>)" '{print $2}')
    lines=$(pcregrep -o '<tr.*?<\/tr>' <<< "<frag>${currencies_table}</frag>" | sed -e ':a' -e 'N' -e '$!ba' | iconv -f ASCII --byte-subst='\x{%02x}')

    while IFS='' read -r row; do
      chunks=$(sed -E -e 's/.*<b>(.*)<\/b><\/td> <td class="right"> ([0-9,]+).*"> ([0-9,]+).*/\1 \2 \3/' <<< $row)
      IFS=' ' read -r -a args <<< "$chunks"

      currency=${args[0]}
      currencySource=$(cut -d "/" -f 2 <<< $currency)
      currencyTarget=$(cut -d "/" -f 1 <<< $currency)

      normalizedBuyDeviza=$(cleanNumber ${args[2]})
      normalizedSellDeviza=$(cleanNumber ${args[1]})

      normalizedAmount="1"

      echo "$normalizedAmount $currencyTarget >> VIRTUAL_RATE { sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource }, DATE: { $syncDate }"
    done <<< "$(tail -n +3 <<< "$lines")"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

