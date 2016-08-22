#!/bin/bash

. common.sh

syncDate="2016-08-22"

#info simmilar IB as RaiffeisenBank, liferay probably under the hood, need probe to retrieve instances id
if online; then
  response=$(request "https://www.moneta.cz/kurzovni-listek#")
  #https://www.moneta.cz/kurzovni-listek?p_p_id=ExchangeRatePortlet_WAR_monetaportletsportlet_INSTANCE_0M6TxpaMbiCx&p_p_lifecycle=2&p_p_state=normal&p_p_mode=view&p_p_resource_id=filterAction&p_p_cacheability=cacheLevelPage&p_p_col_id=column-1&p_p_col_pos=1&p_p_col_count=3&_ExchangeRatePortlet_WAR_monetaportletsportlet_INSTANCE_0M6TxpaMbiCx_exchangeRateDate=01.08.2016

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

