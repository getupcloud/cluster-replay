#!/bin/bash

cd cluster-dump

echo Restoring users...
oc replace -f cluster-users.yaml || oc create -f cluster-users.yaml
echo Restoring identities...
oc get user -o yaml | python ../restore-identity.py cluster-identity.yaml > cluster-identity-restored.yaml
oc replace -f cluster-identity-restored.yaml || oc create -f cluster-identity-restored.yaml

echo Restoring applications...
for ns in */; do
    ns=${ns%/*}
    pushd $ns

    echo Recreating project ${ns}...
    echo "--> ${ns}"
    oc new-project ${ns}

    echo Recreating resources for ${ns}...
    for type in *.yaml; do
        oc create -n ${ns} -f ${type}
    done
    popd
done

if oc get ns getup &>/dev/null; then
    echo Restoring GetupCloud databases...
    for db in mysql-api_getup mysql-usage_getup; do
        dc=${db%_*}
        name=${db#*_}
        pod=$(oc get pod -n getup -l app=$dc -o name|cut -f2 -d/|head -1)
        echo "--> pod=$pod app=$dc db=$name > $db.sql"
        oc -n getup cp $db.sql $pod:/tmp/dump.sql
        oc -n getup rsh $pod scl enable rh-mysql57 "mysqladmin -uroot drop $name --force"
        oc -n getup rsh $pod scl enable rh-mysql57 "mysqladmin -uroot create $name"
        oc -n getup rsh $pod scl enable rh-mysql57 "mysql -uroot $name </tmp/dump.sql"
    done
fi
