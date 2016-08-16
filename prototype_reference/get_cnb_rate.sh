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

syncDate="08.08.2016"

if online; then
  response=$(request "https://www.cnb.cz/cs/financni_trhy/devizovy_trh/kurzy_devizoveho_trhu/denni_kurz.txt?date=${syncDate}")
  if [ $? -eq 0 ]; then
    check=$(head -n 1 <<< "$response")
    dataDate=$(cut -d " " -f 1 <<< $check)
    dataId=$(cut -d "#" -f 2 <<< $check)

    if [[ ! "$syncDate" == "$dataDate" ]]; then
      echo "no data for $syncDate"
      exit 1
    fi

    while IFS='' read -r LINE || [[ -n "$LINE" ]]; do
      amount=$(cut -d "|" -f 3 <<< $LINE)
      currencyTarget=$(cut -d "|" -f 4 <<< $LINE)
      currencySource="CZK"
      rate=$(cut -d "|" -f 5 <<< $LINE)
      rate=${rate//[,]/.}
      inverseAmount=$(lua -e "print(1/$rate*$amount)")
      
      echo "1 $currencySource = $inverseAmount $currencyTarget"
    done <<< "$(awk 'NR > 2' <<< "$response")"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

