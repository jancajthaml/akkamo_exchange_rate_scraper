#!/bin/bash  

online() {
  nc -z 8.8.8.8 53 >/dev/null 2>&1; [ $? -eq 0 ]
}

request() {
  res=$(curl -sw "%{http_code}" $1)
  http_code="${res:${#res}-3}"

  if [[ "$http_code" == "200" ]]; then
    echo "${res:0:${#res}-3}"
    return 0
  else
    return 1
  fi
}

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
      currency=$(awk -F"," '{print $3}' <<< $LINE | tr -d '"' | tr -d ' ')

      buy=$(awk -F"," '{print $6}' <<< $LINE | tr -d '"' | tr -d ' ')
      sell=$(awk -F"," '{print $7}' <<< $LINE | tr -d '"' | tr -d ' ')
      sell=${sell//[,]/.}
      buy=${buy//[,]/.}

      normalizedBuy=$(lua -e "print($sell/$amount)")
      normalizedSell=$(lua -e "print($buy/$amount)")

      echo "1 $currency = sell: $normalizedSell CZK, buy: $normalizedBuy CZK"

    done <<< "$(awk 'NR > 2' <<< "$response")"
    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

