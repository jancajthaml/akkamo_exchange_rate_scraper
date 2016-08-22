#!/bin/bash

. common.sh

syncDate="22.08.2016"

#fixme wrong data sources, javascript only serves for current recalculations for TODAY
#need to use HTML table
if online; then
  response=$(requestPOST "http://www.fio.cz/akcie-investice/dalsi-sluzby-fio/devizove-konverze#kalk --data \"keDni_den=${syncDate}&keDni_submit=Zobrazit\"")

  if [ $? -eq 0 ]; then
    data=$(iconv -f ASCII --byte-subst='\x{%02x}' <<< "$response" | tr -d "\n\r")
    rates=$(pcregrep -o 'kurzy = \K([^;]+)' <<< "$data")

lines=$(python -c "
from __future__ import print_function
import os
import json
import sys
import traceback
rates=${rates}
try:
  for rate in rates:
    # amount source target buy sell
    print('1 {0} {1} {2} {3}'.format(rate['c'], rate['z'], rate['p'], rate['n']))
except Exception:
  exc_type, exc_value, exc_traceback = sys.exc_info()
  print(exc_value)
  print('\n'.join(traceback.format_tb(exc_traceback)))
  sys.exit(1)
") 

    while IFS='' read -r row; do
      IFS=' ' read -r -a args <<< "$row"

      currencyTarget=${args[1]}
      currencySource=${args[2]}

      amount="1"

      normalizedBuyDeviza=$(cleanNumber ${args[3]})
      normalizedSellDeviza=$(cleanNumber ${args[4]})

      normalizedAmount="${args[0]}"
      echo "$normalizedAmount $currencyTarget >> VIRTUAL_RATE { sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource }, DATE: { $syncDate }"
    done <<< "$lines"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

