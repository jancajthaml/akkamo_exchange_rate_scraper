#!/bin/bash  

. common.sh

syncDate="2016-8-11"

if online; then
  response=$(request "https://www.airbank.cz/cs/kurzovni-listek/")
  if [ $? -eq 0 ]; then
    currencies_table=$(tr -d '\011\012\015' <<< $response | awk -v FS="(<div class='contentAjax'>|</table>)" '{print $2}' | awk -v FS="(<tbody>|</tbody>)" '{print $2}')

    echo "<frag>${currencies_table}</frag>"
    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

