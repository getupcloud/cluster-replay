Cluster Replay is a couple of scripts to dump from a cluster and restore into another.

Usage:

    $ KUBECONFIG=cluster-1-kubeconfig ./dump.sh 
    $ KUBECONFIG=cluster-2-kubeconfig ./restore.sh

It's mainly used to migrate GetupCloud's Openshift clusters from clients.
