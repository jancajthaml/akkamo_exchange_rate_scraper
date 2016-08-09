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

syncDate="9.8.2016"

if online; then
  response=$(request "https://www.kb.cz/kurzovni-listek/cs/rl/index.x?format=xml&filterDate=${syncDate}")

  if [ $? -eq 0 ]; then
    # need to retrieve cookie and session first, otherwise returns empty XML
    echo "$response"
    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

