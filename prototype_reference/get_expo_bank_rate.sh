#!/bin/bash

. common.sh

syncDate="2016-08-02"

if online; then
  responseDeviza=$(request "https://www.expobank.cz/fis/rs/sp/public/web/exchangerate/MARKET/${syncDate}?get_param=value")

  if [ $? -eq 0 ]; then
    responseValuta=$(request "https://www.expobank.cz/fis/rs/sp/public/web/exchangerate/CASH/${syncDate}?get_param=value")

    if [ $? -eq 0 ]; then

      echo "$responseDeviza"
      echo "$responseValuta"

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

