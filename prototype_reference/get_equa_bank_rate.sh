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

syncDate="2016-8-11"

if online; then
  response=$(request "https://www.equabank.cz/dulezite-dokumenty/kurzovni-listek?d=2016-8-11")
  if [ $? -eq 0 ]; then
      
    currencies_table=$(awk -v FS="(<div id=\"currency\">|</table>)" '{print $2}' <<< $response | awk -v FS="(<tbody>|</tbody>)" '{print $2}' | sed '/^\s*$/d')

    echo "<frag>${currencies_table}</frag>"

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

