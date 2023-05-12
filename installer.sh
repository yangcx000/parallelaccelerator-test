#!/bin/bash
#
# Copyright 2023 LiAuto authors.
# @yangchunxin
#

if [ $# -lt 5 ]; then
    echo "Usage: $0 [env] [pamaster/paworker] [cluster_name] [etcd_endpoints] [filesystems]"
    exit 1
fi

env=$1
service=$2
cluster_name=$3
etcd_endpoints=$4
filesystemds=$5
curdir=$(pwd)

installPaWorker() {
    while read worker; do
        scp ${curdir}/cmd/worker/paworker root@${worker}:/usr/local/bin
        scp ${curdir}/deploy_paworker.sh root@${worker}:~/
    done < ${curdir}/machines/${env}-workers.txt

    pssh -h ${curdir}/machines/${env}-workers.txt -l root "bash deploy_paworker.sh ${cluster_name} ${etcd_endpoints} ${filesystemds}"
}

installPaMaster() {
    while read master; do
        scp ${curdir}/cmd/master/pamaster root@${master}:/usr/local/bin
        scp ${curdir}/deploy_pamaster.sh root@${master}:~/
    done < ${curdir}/machines/${env}-masters.txt

    pssh -h ${curdir}/machines/${env}-masters.txt -l root "bash deploy_pamaster.sh ${cluster_name} ${etcd_endpoints} ${filesystemds}"
}

case ${service} in
    "pamaster")
        installPaMaster
        ;;
    "paworker")
        installPaWorker
        ;;
    *)
        echo "unknown service name"
esac
