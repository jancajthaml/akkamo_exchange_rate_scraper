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
  response=$(request "https://www.csas.cz/banka/portlets/exchangerates/current.do?csv=1&times=&event=current&day=13&month=8&year=2016")

  #check=$(head -n 1 <<< "$response")
  #dataDate=$(cut -d " " -f 1 <<< $check)

  #if [[ ! "$syncDate" == "$dataDate" ]]; then
    #echo "no data for $syncDate"
    #exit 1
  #fi

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

