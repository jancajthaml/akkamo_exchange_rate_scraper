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

syncDate="09.08.2016" # wanted rates for given rate
#2016-08-09 reference date to check response

if online; then
  urlEncodedDate=$(sed "s/\./\.+/g" <<< $syncDate)

  spoil=$(request "https://www.rb.cz/informacni-servis/informacni-a-online-sluzby/kurzovni-listek")

  probe=$(grep -o '"*https://www.rb.cz/cs/informacni-servis/informacni-a-online-sluzby/kurzovni-listek?[^"]*' <<< "$spoil" | grep -o '"*CurrencyRate_WAR_CurrencyRateportlet_INSTANCE_[^"]*' | head -1)

  ids=$(grep -o '[a-zA-Z_]*_INSTANCE_[^&]*' <<< $probe | perl -pne 's/"(.*)_INSTANCE_([0-9a-z]+)_?/$1:$2/g')

  DynamicNestedPortlet_id=$(grep -o '"*DynamicNestedPortlet[^"]*__' <<< "$ids")
  DynamicNestedPortlet_id=${DynamicNestedPortlet_id##*INSTANCE_}
  DynamicNestedPortlet_id=${DynamicNestedPortlet_id/__/}

  CurrencyRate_WAR_CurrencyRateportlet_id=$(grep -o '"*CurrencyRate_WAR_CurrencyRateportlet[^"]*' <<< "$ids" | head -1)
  CurrencyRate_WAR_CurrencyRateportlet_id=${CurrencyRate_WAR_CurrencyRateportlet_id##*_}

  p_p_id="CurrencyRate_WAR_CurrencyRateportlet_INSTANCE_${CurrencyRate_WAR_CurrencyRateportlet_id}"
  p_p_out="_CurrencyRate_WAR_CurrencyRateportlet_INSTANCE_${CurrencyRate_WAR_CurrencyRateportlet_id}_action"
  p_p_date="_CurrencyRate_WAR_CurrencyRateportlet_INSTANCE_${CurrencyRate_WAR_CurrencyRateportlet_id}_date"
  p_p_col_id="_DynamicNestedPortlet_INSTANCE_${DynamicNestedPortlet_id}__column-1"

  response=$(request "https://www.rb.cz/cs/informacni-servis/informacni-a-online-sluzby/kurzovni-listek?p_p_id=${p_p_id}&p_p_lifecycle=2&p_p_state=normal&p_p_mode=view&p_p_col_id=${p_p_col_id}&p_p_col_count=1&${p_p_date}=${urlEncodedDate}&${p_p_out}=xml")

  if [ $? -eq 0 ]; then
    echo "$response"
    exit 0
  else
    # not yet fool proof, ussually 2-3 tries to hit the correct nodes
    echo "network unreachable, bailing out"
    exit 1
  fi

else
  echo "network offline, nothing to do"
fi