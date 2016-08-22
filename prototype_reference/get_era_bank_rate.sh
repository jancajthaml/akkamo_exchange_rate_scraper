#!/bin/bash

. common.sh

syncDate="9.8.2016"

if online; then

  #devizy
  response=$(requestPOST "https://www.erasvet.cz/informace-k-produktum/kurzovni-listek-meny/stranky/kurz-meny.aspx?p_auth=9ZVszP0k&p_p_id=exchangeRates_WAR_portalfoundation&p_p_lifecycle=1&p_p_state=normal&p_p_mode=view&p_p_col_id=column-main&p_p_col_count=2&action=list --data \"date:${syncDate}\"")

  if [ $? -eq 0 ]; then
    
    echo "$response"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

