#!/bin/bash  

. common.sh

syncDate="12.08.2016"

if online; then
  response=$(request "http://www.ingbank.cz/o-ing-bank/kurzovni-listek/?date=${syncDate}")
  if [ $? -eq 0 ]; then
    currencies_table=$(tr -d '\011\012\015' <<< $response | awk -v FS="(<table class='tableBasic' cellSpacing='0' cellPadding='0' border='0' summary=''>|</table>)" '{print $2}' | awk -v FS="(<tbody>|</tbody>)" '{print $2}')
    data="<frag>${currencies_table}</frag>"

    #xpath is extremely slow in this case, change to sed or awk in future
    lines=$(xpath 'count(//frag/tr)' <<< $data 2> /dev/null)

    for ((i=0; i<${lines}; i++)); do
      row=$(xpath "(//frag/tr)[$((i + 1))]" <<< $data 2> /dev/null)

      currency=$(xpath "(//tr/td[1]/b/text()" <<< $row 2> /dev/null)

      if [ ! -z $currency ]; then
        currencySource=$(cut -d "/" -f 1 <<< $currency)
        currencyTarget=$(cut -d "/" -f 2 <<< $currency)

        buy=$(xpath "(//tr/td[2]/text()" <<< $row 2> /dev/null | tr -cd '[[:digit:]].,_-')
        sell=$(xpath "(//tr/td[3]/text()" <<< $row 2> /dev/null | tr -cd '[[:digit:]].,_-')

        sell=${sell//[,]/.}
        buy=${buy//[,]/.}

        echo "1 $currencySource = sell: $sell $currencyTarget, buy: $buy $currencyTarget"
      fi
      
    done

    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

