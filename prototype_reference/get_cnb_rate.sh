#!/bin/bash  

. common.sh

syncDate="12.08.2016"

if online; then
  response=$(request "https://www.cnb.cz/cs/financni_trhy/devizovy_trh/kurzy_devizoveho_trhu/denni_kurz.txt?date=${syncDate}")
  
  if [ $? -eq 0 ]; then
    dataDate=$(head -n 1 <<< "$response")
    dataDate=${dataDate%% *}

    if [[ "$syncDate" != "$dataDate" ]]; then
      echo "no data for $syncDate"
      exit 1
    fi

    while IFS='' read -r LINE || [[ -n "$LINE" ]]; do
      currencyTarget=$(cut -d "|" -f 4 <<< $LINE)
      currencySource="CZK"

      amount=$(cut -d "|" -f 3 <<< $LINE)

      rate=$(cut -d "|" -f 5 <<< $LINE | sed -e 's/,/./g')
      normalizedRate=$(calculate "$rate / $amount")
      
      echo "1 $currencyTarget = $normalizedRate $currencySource"
    done <<< "$(tail -n +3 <<< "$response")"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

