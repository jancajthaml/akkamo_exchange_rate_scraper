#!/bin/bash  

. common.sh

syncDate="12.8.2016"

if online; then
  day=$(cut -d "." -f 1 <<< $syncDate)
  month=$(cut -d "." -f 2 <<< $syncDate)
  year=$(cut -d "." -f 3 <<< $syncDate)

  day=${day#0}
  month=${month#0}
  year=${year#0}

  response=$(request "https://www.csas.cz/banka/portlets/exchangerates/current.do?csv=1&times=&event=current&day=${day}&month=${month}&year=${year}")
  if [ $? -eq 0 ]; then

    #"Platnost od:","12.8.2016" ,""," "," ","Devizy"," "," ","Valuty"," "," ","ČNB",
    check=$(head -n 1 <<< "$response")
    dataDate=$(awk -F"," '{print $2}' <<< $check | tr -d '"' | tr -d ' ')

    if [[ ! "$syncDate" == "$dataDate" ]]; then
      echo "no data for $syncDate"
      exit 1
    fi
    #"Zemì","Jednotka","Mìna","Zmìna [%]", ,"Nákup","Prodej","Støed","Nákup","Prodej","Støed","Støed",
    while IFS='' read -r LINE || [[ -n "$LINE" ]]; do
      amount=$(awk -F"," '{print $2}' <<< $LINE | tr -d '"' | tr -d ' ')
      currencyTarget=$(awk -F"," '{print $3}' <<< $LINE | tr -d '"' | tr -d ' ')
      currencySource="CZK"

      buy=$(awk -F"," '{print $6}' <<< $LINE | tr -d '"' | tr -d ' ')
      sell=$(awk -F"," '{print $7}' <<< $LINE | tr -d '"' | tr -d ' ')
      sell=${sell//[,]/.}
      buy=${buy//[,]/.}

      normalizedBuy=$(lua -e "print($sell/$amount)")
      normalizedSell=$(lua -e "print($buy/$amount)")

      echo "1 $currencyTarget = sell: $normalizedSell $currencySource, buy: $normalizedBuy $currencySource"

    done <<< "$(awk 'NR > 2' <<< "$response")"
    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

