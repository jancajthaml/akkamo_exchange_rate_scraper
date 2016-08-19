#!/bin/bash  

. common.sh

syncDate="2016-08-19"

#last 90days -> http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml
#from forever -> https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.xml

if online; then
  #check if syncDate is for today or historic here
  response=$(request "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml")

  if [ $? -eq 0 ]; then

    dataDate=$(sed -n "s/.* time=\'\(.*\)\'.*/\1/p" <<< "$response")

    if [[ "$syncDate" != "$dataDate" ]]; then
      echo "no data for $syncDate"
      exit 1
    fi

    lines=$(sed -n "s/.*<Cube currency=\'\(.*\)\' rate=\'\(.*\)\'\/>.*/\1 \2/p" <<< "$response" | iconv -f ASCII --byte-subst='\x{%02x}')

    while IFS='' read -r row; do
      currencyTarget=${row%% *}
      currencySource="EUR"
      rate=$(cleanNumber ${row##* })

      echo "1 $currencySource = $rate $currencyTarget"
    done <<< "$lines"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

