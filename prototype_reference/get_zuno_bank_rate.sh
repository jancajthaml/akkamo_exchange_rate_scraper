#!/bin/bash  

. common.sh

syncDate="2016-8-11"

if online; then
  response=$(request "https://www.zuno.cz/pomoc/uzitecne-informace/kurzovni-listek/")
  if [ $? -eq 0 ]; then
    currencies_table=$(tr -d '\011\012\015' <<< $response | awk -v FS="(<table class=\"ztable irates\">|</table>)" '{print $2}')
    lines=$(pcregrep -o '<tr.*?<\/tr>' <<< "<frag>${currencies_table}</frag>" | sed -e ':a' -e 'N' -e '$!ba')

    while IFS='' read -r row; do
      sanitized=$(iconv -f ASCII --byte-subst='\x{%02x}' <<< $row)
      chunks=$(sed -E -e 's/.*<td>(.*)<\/td>.*<td>(.*)<\/td>.*<td>(.*)<\/td>.*<td>(.*)<\/td>.*<td>(.*)<\/td>.*/\1 \2 \3 \5/' -e 's/,/./g' <<< $sanitized)

      currencySource=$(cut -d " " -f 1 <<< $chunks)
      currencyTarget=$(cut -d " " -f 2 <<< $chunks)

      sell=$(cut -d " " -f 3 <<< $chunks | tr -cd '[[:digit:]].,_-')
      buy=$(cut -d " " -f 4 <<< $chunks | tr -cd '[[:digit:]].,_-')

      echo "1 $currencySource = sell: $sell $currencyTarget, buy: $buy $currencyTarget"

    done <<< "$(tail -n +2 <<< "$lines")"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

