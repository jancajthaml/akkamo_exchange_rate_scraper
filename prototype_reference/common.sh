#!/bin/bash

# checks if network is up agains Google DNS
function online {
  nc -z 8.8.8.8 53 >/dev/null 2>&1
  [ $? -eq 0 ]
}

# performs HTTP GET request to $1 and append cookie if neccessary under $2
# if response HTTP code is 200 returns response body
function request {
  res=$([[ ! -z $2 ]] && curl --cookie "${2}" -sw "%{http_code}" $1 || curl -sw "%{http_code}" $1)
  http_code="${res:${#res}-3}"

  if [[ "$http_code" == "200" ]]; then
    echo "${res:0:${#res}-3}"
    return 0
  else
    return 1
  fi
}

# performs HTTP header-only GET request to $1 and retrieves http-only header
# for cookie set
function getCookie {
  res=$(curl -IL -sw "%{http_code}" $1)
  http_code="${res:${#res}-3}"
  if [[ "$http_code" == "200" ]]; then
    pcregrep -o 'Set-Cookie: \K([^;]+)' <<< "${res:0:${#res}-3}"
    return 0
  else
    return 1
  fi
}

function cleanNumber {
  sed -e 's/[^0-9.-]\+/ /g;s/^ \+\| \+$//g' -e 's/,/./g' -e 's/^\./0./;s/0*$//' <<< $1
}

# so far fastest and still precise mean to calculate something
function calculate {
  x=$(cleanNumber "scale=35; $1")
  bc -l <<< $x | sed 's/^\./0./;s/0*$//'
}