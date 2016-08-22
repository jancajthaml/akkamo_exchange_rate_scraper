#!/bin/bash

. common.sh

syncDate="22.08.2016"

if online; then

  #devizy
  response=$(request "http://www.oberbank.at/OBK_webp/OBK/Application/Rechner/CZ/Fixing/Fixing_cz_export.jsp?dat1=${syncDate}&dat2=${syncDate}&dk=on&fn=on")

  #valuty
  #response=$(request "http://www.oberbank.at/OBK_webp/OBK/Application/Rechner/CZ/Fixing/Fixing_cz_export.jsp?dat1=${syncDate}&dat2=${syncDate}&nk=on&fn=on")  

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

