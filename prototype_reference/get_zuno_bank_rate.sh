#!/bin/bash  

. common.sh

syncDate="2016-8-11"

if online; then
  response=$(request "https://www.zuno.cz/pomoc/uzitecne-informace/kurzovni-listek/")

  if [ $? -eq 0 ]; then
    currencies_table=$(tr -d '\011\012\015' <<< $response | awk -v FS="(<table class=\"ztable irates\">|</table>)" '{print $2}')
    lines=$(pcregrep -o '<tr.*?<\/tr>' <<< "<frag>${currencies_table}</frag>" | sed -e ':a' -e 'N' -e '$!ba' | iconv -f ASCII --byte-subst='\x{%02x}' | tail -n +2)

    while IFS='' read -r row; do
      chunks=$(sed -E -e 's/.*<td>(.*)<\/td>.*<td>(.*)<\/td>.*<td>(.*)<\/td>.*<td>(.*)<\/td>.*<td>(.*)<\/td>.*/\1 \2 \3 \5/' -e 's/,/./g' <<< $row)
      IFS=' ' read -r -a args <<< "$chunks"

      currencySource=${args[0]}
      currencyTarget=${args[1]}

      sell=$(cleanNumber ${args[2]})
      buy=$(cleanNumber ${args[3]})

      echo "1 $currencySource = sell: $sell $currencyTarget, buy: $buy $currencyTarget"
    done <<< "$lines"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

