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

syncDate="09.08.2016"

if online; then
  urlEncodedDate=$(sed "s/\./\.+/g" <<< $syncDate)

  spoil=$(request "https://www.rb.cz/informacni-servis/informacni-a-online-sluzby/kurzovni-listek")
  ids=$(grep -o '"[a-zA-Z_]*_INSTANCE_[^"]*' <<< $spoil | perl -pne 's/"(.*)_INSTANCE_([0-9a-z]+)_?/$1: $2/g')
  DynamicNestedPortlet_id=$(grep -o '"*DynamicNestedPortlet[^"]*' <<< "$ids" | head -1 | cut -d " " -f 2)
  CurrencyRate_WAR_CurrencyRateportlet_id=$(grep -o '"*CurrencyRate_WAR_CurrencyRateportlet[^"]*'  <<< "$ids" | head -1 | cut -d " " -f 2)

  p_p_id="CurrencyRate_WAR_CurrencyRateportlet_INSTANCE_${CurrencyRate_WAR_CurrencyRateportlet_id}"
  p_p_col_id="_DynamicNestedPortlet_INSTANCE_${DynamicNestedPortlet_id}__column-1"
  p_p_out="_CurrencyRate_WAR_CurrencyRateportlet_INSTANCE_${CurrencyRate_WAR_CurrencyRateportlet_id}_action"
  p_p_date="_CurrencyRate_WAR_CurrencyRateportlet_INSTANCE_${CurrencyRate_WAR_CurrencyRateportlet_id}_date"

  response=$(request "https://www.rb.cz/cs/informacni-servis/informacni-a-online-sluzby/kurzovni-listek?p_p_id=${p_p_id}&p_p_lifecycle=2&p_p_state=normal&p_p_mode=view&p_p_col_id=$p_p_col_id&p_p_col_count=1&${p_p_date}=${urlEncodedDate}&${p_p_out}=xml")

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