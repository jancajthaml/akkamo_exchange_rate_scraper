#!/bin/bash  

. common.sh

syncDate="12.08.2016"

if online; then
  response=$(request "http://www.ingbank.cz/o-ing-bank/kurzovni-listek/?date=${syncDate}")
  if [ $? -eq 0 ]; then
    currencies_table=$(tr -d '\011\012\015' <<< $response | awk -v FS="(<table class='tableBasic' cellSpacing='0' cellPadding='0' border='0' summary=''>|</table>)" '{print $2}' | awk -v FS="(<tbody>|</tbody>)" '{print $2}')

    echo "<frag>${currencies_table}</frag>"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

