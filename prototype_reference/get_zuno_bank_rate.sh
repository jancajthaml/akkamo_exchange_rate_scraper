#!/bin/bash  

. common.sh

syncDate="2016-8-11"

if online; then
  response=$(request "https://www.zuno.cz/pomoc/uzitecne-informace/kurzovni-listek/")
  if [ $? -eq 0 ]; then
    currencies_table=$(tr -d '\011\012\015' <<< $response | awk -v FS="(<table class=\"ztable irates\">|</table>)" '{print $2}')
    data="<frag>${currencies_table}</frag>"

    #xpath is extremely slow in this case, change to sed or awk in future
    lines=$(xpath 'count(//frag/tr)' <<< $data 2> /dev/null)

    for ((i=1; i<${lines}; i++)); do
      row=$(xpath "(//frag/tr)[$((i + 1))]" <<< $data 2> /dev/null)
        
      currencySource=$(xpath "(//tr/td[1]/text()" <<< $row 2> /dev/null)
      currencyTarget=$(xpath "(//tr/td[2]/text()" <<< $row 2> /dev/null)

      sell=$(xpath "(//tr/td[3]/text()" <<< $row 2> /dev/null | tr -cd '[[:digit:]].,_-')
      buy=$(xpath "(//tr/td[5]/text()" <<< $row 2> /dev/null | tr -cd '[[:digit:]].,_-')

      sell=${sell//[,]/.}
      buy=${buy//[,]/.}

      echo "1 $currencySource = sell: $sell $currencyTarget, buy: $buy $currencyTarget"

    done

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

