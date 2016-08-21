#!/bin/bash  

. common.sh

syncDate="19/08/2016"

data=""

function indexFor {
  bc -l <<< "$1 + $2 * 16"
}
function valueAt {
  index=$(bc -l <<< "$1 + $2 * 16")
  #echo "$index"
  echo ${data[$index]}
}

if online; then
  # 2D array
  response=$(request "http://www.citibank.cz/czech/gcb/personal_banking/data/rates.txt")

  if [ $? -eq 0 ]; then
    
    # insanely slow but meh...
    row=0
    while IFS='' read -r R; do
      IFS=',' read -r -a args <<< "$R"
      for ((col=0;col<${#args[@]};col++)) do
        data[$(indexFor $col $row)]=${args[$col]}
      done
      let "row++"
    done <<< "$(head -14 <<< "$response")"

    dataDate=$(valueAt 10 13)

    if [[ "$syncDate" != "$dataDate" ]]; then
      echo "no data for $syncDate -> \"$dataDate\" != \"$syncDate\""
      exit 1
    fi

    #todo extract following from script
    # var startrownum = 2; // Starting row number
    # var endrownum = 12; // Ending row number

    # var rowsZkr = ["USD","GBP","JPY","CAD","EUR","CHF","HUF","AUD","DKK","PLN","SEK"];
    # var rowsNas = ["1"  ,"1"  ,"100","1"  ,"1"  ,"1" ,"100","1"  ,"1"  ,"1"  ,"1"]; 

    IFS=' ' read -r -a currencies <<< "X X USD GBP JPY CAD EUR CHF HUF AUD DKK PLN SEK"
    IFS=' ' read -r -a amounts <<< "X X 1 1 100 1 1 1 100 1 1 1 1"

    for ((row=2;row<13;row++)) do

      #devizy nakup/prodej
      sell=$(valueAt 9 $row)
      buy=$(valueAt 10 $row)

      #valuty nakup/prodej
      #rowDataC=$(valueAt 11 $row)
      #rowDataD=$(valueAt 12 $row)

      currencyTarget=${currencies[$row]}
      currencySource="CZK"

      amount=${amounts[$row]}

      normalizedBuy=$(calculate "$buy / $amount")
      normalizedSell=$(calculate "$sell / $amount")

      echo "1 $currencyTarget = sell: $normalizedSell $currencySource, buy: $normalizedBuy $currencySource"
    done
    exit 0
  else
    echo "network unreachable, bailing out"
    exit 1
  fi
else
  echo "network offline, nothing to do"
fi

