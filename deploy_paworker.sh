#!/bin/bash
#
# Copyright 2022 LiAuto authors.
# @yangchunxin
#

if [ $# -lt 3 ]; then
    echo "Usage: $0 [cluster_name] [etcd_endpoints] [filesystems]"
    exit 1
fi

# parameters
cluster_name=$1
etcd=$2
filesystems=$3

# paworkers
ports=("7000" "7001")

mkdir -p /etc/parallelaccelerator

echo CLUSTER_NAME=${cluster_name} >> /etc/parallelaccelerator/paworker.conf
echo PAWORKER_ADDR=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1) >> /etc/parallelaccelerator/paworker.conf
echo ETCD=${etcd} >> /etc/parallelaccelerator/paworker.conf
echo FILESYSTEMS=${filesystems} >> /etc/parallelaccelerator/paworker.conf
echo PARALLELS=52 >> /etc/parallelaccelerator/paworker.conf
echo PARALLELS_PER_TASK=8 >> /etc/parallelaccelerator/paworker.conf

cat << EOF > /lib/systemd/system/paworker@.service
[Unit]
Description=ParallelAccelerator Worker
After=network-online.target

[Service]
EnvironmentFile=/etc/parallelaccelerator/paworker.conf
ExecStart=/usr/local/bin/paworker \\
    --cluster_name \${CLUSTER_NAME} \\
    --addr \${PAWORKER_ADDR}:%i \\
    --etcd_endpoints \${ETCD} \\
    --filesystems \${FILESYSTEMS} \\
    --parallels \${PARALLELS} \\
    --parallels_per_task \${PARALLELS_PER_TASK}

Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=1048576

# Specifies the maximum number of threads this process can create
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
for port in ${ports[@]};do
    systemctl enable paworker@${port}.service
    systemctl start paworker@${port}.service
    systemctl status -l paworker@${port}.service
done
