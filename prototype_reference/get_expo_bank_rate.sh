#!/bin/bash

. common.sh

syncDate="2016-08-22"

if online; then
  responseDeviza=$(request "https://www.expobank.cz/fis/rs/sp/public/web/exchangerate/MARKET/${syncDate}?get_param=value")

  if [ $? -eq 0 ]; then
    responseValuta=$(request "https://www.expobank.cz/fis/rs/sp/public/web/exchangerate/CASH/${syncDate}?get_param=value")

    if [ $? -eq 0 ]; then

      lines=$(python -c "
from __future__ import print_function
import os
import json
import sys
import traceback
syncDate='${syncDate}'
valutas=${responseValuta}
devizas=${responseDeviza}
merge={}
try:
  for valuta in valutas:
    if syncDate == valuta['dateCreated'].split('T')[0]:
      merge[valuta['currency']] = {
        'buyValuta': valuta['buyRate'],
        'sellValuta': valuta['saleRate'],
        'amountValuta': valuta['quotationUnit']
      }
  for deviza in devizas:
    if syncDate == deviza['dateCreated'].split('T')[0]:

      if deviza['currency'] in merge:
        merge[deviza['currency']]['buyDeviza'] = deviza['buyRate']
        merge[deviza['currency']]['sellDeviza'] = deviza['saleRate']
        merge[deviza['currency']]['amountDeviza'] = deviza['quotationUnit']
      else:
        merge[deviza['currency']] = {
          'buyDeviza': deviza['buyRate'],
          'sellDeviza': deviza['saleRate'],
          'amountDeviza': deviza['quotationUnit']
        }
  for currency, data in merge.iteritems():
    print('{0} {1} {2} {3} {4} {5} {6}'.format(
      currency,
      data.get('amountDeviza', '-'),
      data.get('buyDeviza', '-'),
      data.get('sellDeviza', '-'),
      data.get('amountValuta', '-'),
      data.get('buyValuta', '-'),
      data.get('sellValuta', '-')
    ))
    
except Exception:
  exc_type, exc_value, exc_traceback = sys.exc_info()
  print(exc_value)
  print('\n'.join(traceback.format_tb(exc_traceback)))
  sys.exit(1)
") 

      while IFS='' read -r row; do
        IFS=' ' read -r -a args <<< "$row"

        currencyTarget=${args[0]}
        currencySource="CZK"

        normalizedAmount="1"

        #devizy nakup/prodej
        amountDeviza=${args[1]}
        normalizedBuyDeviza=$(calculate "${args[2]} / ${amountDeviza}")
        normalizedSellDeviza=$(calculate "${args[3]} / ${amountDeviza}")

        #valuty nakup/prodej
        amountValuta=${args[4]}
        buyValuta=${args[5]}
        sellValuta=${args[6]}

        if [[ "$amountValuta" == "-" || "$buyValuta" == "-" || "$sellValuta" == "-" ]]; then
          echo "$normalizedAmount $currencyTarget >> VIRTUAL_RATE { sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource }, DATE: { $syncDate }"
        else
          normalizedBuyValuta=$(calculate "$buyValuta / $amountValuta")
          normalizedSellValuta=$(calculate "$sellValuta / $amountValuta")

          echo "$normalizedAmount $currencyTarget >> VIRTUAL_RATE { sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource }, CASH_RATE { sell: $normalizedSellValuta $currencySource, buy: $normalizedBuyValuta $currencySource }, DATE: { $syncDate }"
        fi

        #amount=${args[1]}

        #normalizedBuyDeviza=$(calculate "${args[3]} / $amount")
        #normalizedSellDeviza=$(calculate "${args[2]} / $amount")

        #normalizedAmount="1"

        #echo "$normalizedAmount $currencyTarget >> VIRTUAL_RATE { sell: $normalizedSellDeviza $currencySource, buy: $normalizedBuyDeviza $currencySource }, DATE: { $syncDate }"
      done <<< "$lines"

      exit 0
    else
      echo "network unreachable, bailing out"
      exit 1
    fi

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

