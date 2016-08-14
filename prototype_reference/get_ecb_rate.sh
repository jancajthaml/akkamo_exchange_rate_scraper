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

read_dom () {
  local IFS=\>
  read -d \< ENTITY CONTENT
  local RET=$?
  TAG_NAME=${ENTITY%% *}
  ATTRIBUTES=${ENTITY#* }
  ATTRIBUTES=${ATTRIBUTES%/}
  return $RET
}

syncDate="2016-08-12"

parse_dom () {
  if [[ $TAG_NAME = "Cube" ]] ; then
    eval local $ATTRIBUTES
    if [[ $time ]]; then
      if [[ ! "$time" == "$syncDate" ]]; then
        echo "no data for $syncDate"
        exit 1
      fi
    elif [[ $currency && $rate ]]; then
      echo "1 EUR = $rate $currency"
    fi
  fi
}

#last 90days -> http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml
#from forever -> https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.xml

if online; then
  #check if syncDate is for today or historic here
  response=$(request "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml")
  if [ $? -eq 0 ]; then
    while read_dom; do
      parse_dom
    done  <<< "$response"
    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

