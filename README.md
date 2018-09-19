# Cluster Replay

Cluster Replay is a couple of scripts to dump from a cluster and restore into another.

Usage:

```
$ KUBECONFIG=cluster-1-kubeconfig ./dump.sh
$ KUBECONFIG=cluster-2-kubeconfig ./restore.sh
```

It's mainly used to migrate GetupCloud's Openshift clusters from clients.

## Supported environment variables
-------------------------------

### EXCLUDE_NAMESPACES

Space-separated list of namespaces to ignore.

Default
```
default kube-public kube-system logging management-infra
openshift openshift-grafana openshift-infra openshift-metrics
openshift-node openshift-web-console getup
```

### INCLUDE_CLUSTERROLES

Space-separated list of ClusterRoles to dump

### INCLUDE_CLUSTERROLEBINDINGS

Space-separated list of ClusterRoleBindings to dump
