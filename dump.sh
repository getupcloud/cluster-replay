#!/bin/bash

NS=${1:-default}
itens=( "dc" "svc" "bc" "routes" "ds" "rolebinding" "secrets" "imagestream" "users" "identity" "sa" "configmap" )
mkdir dump && touch dump/env.txt
  
for i in "${itens[@]}"
do
 
  object=$(oc -n $NS get ${i} | cut -d' ' -f1 | grep -vi "NAME")
  echo -e "${object}" >> dump/env.txt
  while read line; do

    cd dump && mkdir -p "${line}"
    oc -n $NS export ${i}/"${line}" -o yaml --as-template=${i}-"${line}" >> ${i}-"${line}".yaml
    mv ${i}-"${line}".yaml "${line}"
 
  done < dump/env.txt
done



