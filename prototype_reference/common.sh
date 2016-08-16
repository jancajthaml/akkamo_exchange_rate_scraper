#!/bin/bash

online() {
  nc -z 8.8.8.8 53 >/dev/null 2>&1; [ $? -eq 0 ]
}

request() {
  res=$([[ ! -z $2 ]] && curl --cookie "${2}" -sw "%{http_code}" $1 || curl -sw "%{http_code}" $1)
  http_code="${res:${#res}-3}"

  if [[ "$http_code" == "200" ]]; then
    echo "${res:0:${#res}-3}"
    return 0
  else
    return 1
  fi
}


getCookie() {
  res=$(curl -IL -sw "%{http_code}" $1)
  http_code="${res:${#res}-3}"
  if [[ "$http_code" == "200" ]]; then
    grep -o '^Set-Cookie: .*' <<< "${res:0:${#res}-3}"| perl -pne 's/Set-Cookie: (.*)?/$1/g' | cut -d ";" -f 1
    return 0
  else
    return 1
  fi
}