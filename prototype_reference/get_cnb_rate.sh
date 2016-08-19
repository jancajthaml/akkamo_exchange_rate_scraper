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

    data=$(tail -n +3 <<< "$response" | iconv -f ASCII --byte-subst='\x{%02x}')

    while IFS='' read -r LINE || [[ -n "$LINE" ]]; do
      IFS='|' read -r -a args <<< "$LINE"

      currencyTarget=${args[3]}
      currencySource="CZK"

      amount=$(cleanNumber ${args[2]})
      rate=$(cleanNumber ${args[4]})

      normalizedRate=$(calculate "$rate / $amount")
      
      echo "1 $currencyTarget = $normalizedRate $currencySource"
    done <<< "$data"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

