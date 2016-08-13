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

syncDate="2016-08-12"

if online; then
  response=$(request "https://www.csob.cz/portal/lide/produkty/kurzovni-listky/kurzovni-listek/-/date/kurzy.txt")

  check=$(head -n 1 <<< "$response")
  dataDate=$(cut -d " " -f 1 <<< $check)

  if [[ ! "$syncDate" == "$dataDate" ]]; then
    echo "no data for $syncDate"
    exit 1
  fi

  if [ $? -eq 0 ]; then
    while IFS='' read -r LINE || [[ -n "$LINE" ]]; do
      #Země;Množství;Měna;Změna;Nákup;Prodej;Střed;Nákup;Prodej;Střed
      country=$(cut -d ";" -f 1 <<< $LINE)
      amount=$(cut -d ";" -f 2 <<< $LINE)
      currency=$(cut -d ";" -f 3 <<< $LINE)
      buy=$(cut -d ";" -f 5 <<< $LINE)
      sell=$(cut -d ";" -f 6 <<< $LINE)
      sell=${sell//[,]/.}
      buy=${buy//[,]/.}

      normalizedBuy=$(lua -e "print($sell/$amount)")
      normalizedSell=$(lua -e "print($buy/$amount)")

      echo "1 $currency = sell: $normalizedSell CZK, buy: $normalizedBuy CZK"

      
    done <<< "$(awk 'NR > 4' <<< "$response")"
    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

