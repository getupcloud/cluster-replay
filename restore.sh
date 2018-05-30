#!/bin/bash

itens=("dc" "svc" "bc" "routes" "ds" "rolebinding" "secrets" "imagestream" "sa" "configmap")
touch restore.txt
rm *.yaml
object=$(ls) && echo -e "${object}" >> restore.txt

for i in "${itens[@]}"
do
  while read line; do  
    curl -Lv -H "Authorization: Bearer ${token} "https://${url}/api/v1/project/ --data "{\"name\":\""${line}"\",\"family\":\"default\"}" -H content-type:application/json
    oc create -f "${line}"
    oc process  ${i}-"${line}" | oc create -f - -n"${line}" 
  done < restore.txt
done
