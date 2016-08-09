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

#calc() { awk "BEGIN{print $*}"; }

syncDate="08.08.2016"

if online; then
  urlEncodedDate=$(sed "s/\./\.%20/g" <<< $syncDate)
  response=$(request "https://www.rb.cz/cs/informacni-servis/informacni-a-online-sluzby/kurzovni-listek?action=xml&date=${urlEncodedDate}")

  # info wont work just like that

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

