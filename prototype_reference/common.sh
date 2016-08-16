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
    pcregrep -o 'Set-Cookie: \K([^;]+)' <<< "${res:0:${#res}-3}"
    return 0
  else
    return 1
  fi
}


calculate() {
  bc -l <<< "scale=35; $1" | sed 's/^\./0./;s/0*$//'
}