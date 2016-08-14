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
    dataDate=$(sed -n -e 's/.*<date>\(.*\)<\/date>.*/\1/p' <<< $response | awk -F"," '{print $1}')
    day=$(cut -d "." -f 1 <<< $dataDate)
    month=$(cut -d "." -f 2 <<< $dataDate)
    year=$(cut -d "." -f 3 <<< $dataDate)

    day=${day#0}
    month=${month#0}
    year=${year#0}

    if [[ ! "$syncDate" == "$day.$month.$year" ]]; then
      echo "no data for $syncDate"
      exit 1
    fi

    echo "$response"
    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

