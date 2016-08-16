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

syncDate="2016-8-16"

if online; then
  response=$(request "https://www.equabank.cz/dulezite-dokumenty/kurzovni-listek?d=${syncDate}")
  if [ $? -eq 0 ]; then
      
    currencies_table=$(tr -d '\011\012\015' <<< $response | awk -v FS="(<div id=\"currency\">|</table>)" '{print $2}' | awk -v FS="(<tbody>|</tbody>)" '{print $2}')
    data="<frag>${currencies_table}</frag>"
    
    #xpath is extremely slow in this case, change to sed or awk in future
    lines=$(xpath 'count(//frag/tr)' <<< $data 2> /dev/null)

    for ((i=0; i<${lines}; i++)); do
      row=$(xpath "(//frag/tr)[$((i + 1))]" <<< $data 2> /dev/null)
      
      currency=$(xpath "//tr/td[contains(@class,'cell-currency')]/span/text()" <<< $row 2> /dev/null)
      sell=$(xpath "//tr/td[contains(@class,'cell-sell')]/text()" <<< $row 2> /dev/null)
      buy=$(xpath "//tr/td[contains(@class,'cell-buy')]/text()" <<< $row 2> /dev/null)

      sell=${sell//[,]/.}
      buy=${buy//[,]/.}

      echo "1 $currency = sell: $sell CZK, buy: $buy CZK"
    done

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

