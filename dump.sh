#!/bin/bash

namespaces=$(oc get ns -o name | cut -f2 -d/)
types="routes services deploymentconfigs statefulsets rolebindings secrets imagestreams serviceaccounts configmaps templates"

rm -rf cluster-dump
mkdir cluster-dump
cd cluster-dump

for ns in $namespaces; do
    [ $ns == default               ] && continue
    [ $ns == getup                 ] && continue
    [ $ns == kube-public           ] && continue
    [ $ns == kube-system           ] && continue
    [ $ns == logging               ] && continue
    [ $ns == management-infra      ] && continue
    [ $ns == openshift             ] && continue
    [ $ns == openshift-grafana     ] && continue
    [ $ns == openshift-infra       ] && continue
    [ $ns == openshift-metrics     ] && continue
    [ $ns == openshift-node        ] && continue
    [ $ns == openshift-web-console ] && continue

    mkdir -p $ns
    for type in $types; do
        echo "--> $ns/$type"
        oc export -n $ns $type > $ns/$type.yaml
    done
done

echo Dumping cluster objects to cluster.yaml
for type in users identity; do
    echo "--> $type"
    oc export $type > cluster-$type.yaml
done

if oc get ns getup &>/dev/null; then
    echo Dumping getup databases
    for db in mysql-api_getup mysql-usage_getup; do
        dc=${db%_*}
        name=${db#*_}
        echo "--> app=$dc db=$name > $db.sql"
        oc -n getup rsh dc/$dc scl enable rh-mysql57 "mysqldump -uroot $name" > $db.sql
    done
fi
