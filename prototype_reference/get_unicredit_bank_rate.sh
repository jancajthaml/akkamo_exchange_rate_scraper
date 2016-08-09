#!/bin/bash  

online() {
  nc -z 8.8.8.8 53 >/dev/null 2>&1; [ $? -eq 0 ]
}

get_cookie() {
  res=$(curl -IL -sw "%{http_code}" $1)
  http_code="${res:${#res}-3}"
  if [[ "$http_code" == "200" ]]; then
    grep -o '^Set-Cookie: .*' <<< "${res:0:${#res}-3}"| perl -pne 's/Set-Cookie: (.*)?/$1/g' | cut -d ";" -f 1
    return 0
  else
    return 1
  fi
}

request() {
  res=$(curl --cookie "${2}" -sw "%{http_code}" $1)
  http_code="${res:${#res}-3}"

  if [[ "$http_code" == "200" ]]; then
    echo "${res:0:${#res}-3}"
    return 0
  else
    return 1
  fi
}

syncDate="2016-08-09"

if online; then
  # fixme somewhat cleaner and more universal, lot of hardcoding there
  cookies=$(get_cookie "https://www.unicreditbank.cz/cs/obcane.html")
  response=$(request "https://www.unicreditbank.cz/cs/exchange_rates_xml.exportxml.html" ${cookies})

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

