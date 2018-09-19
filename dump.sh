#!/bin/bash

all_ns=$(oc get ns -o name --no-headers | cut -f2 -d/)
exclude_ns="${EXCLUDE_NS:-default kube-public kube-system logging management-infra openshift openshift-grafana openshift-infra openshift-metrics openshift-node openshift-web-console getup}"
types_to_dump=(
    1-secrets
    2-serviceaccounts
    3-rolebindings
    4-configmaps
    4-templates
    5-imagestreams
    6-deployments
    6-deploymentconfigs
    6-statefulsets
    7-buildconfigs
    8-services
    9-ingress
    9-routes
)

rm -rf cluster-dump
mkdir cluster-dump
cd cluster-dump

for ns in $all_ns; do
    grep -qw $ns <<<$exclude_ns && continue

    echo  "--> Project: $ns"
    mkdir -p $ns
    oc export ns $ns > $ns/0-namespace.yaml

    for type in ${types_to_dump[*]}; do
        type_name=${type#*-}
        echo -n "  --> $type_name "
        oc export -n $ns ${type_name} > $ns/$type.yaml 2>/dev/null
        echo "[$(grep -e '^-' $ns/$type.yaml |wc -l)]"
    done
done

echo Dumping users
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
