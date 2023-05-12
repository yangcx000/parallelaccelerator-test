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
inst_id=0
parallels_per_worker=128
send_batch_size=32
recursion_thread_num=6
prefix_levels_use_delimiter=10
etcd=$2
filesystems=$3

mkdir -p /etc/parallelaccelerator

echo CLUSTER_NAME=${cluster_name} >> /etc/parallelaccelerator/pamaster.conf
echo INST_ID=${inst_id} >> /etc/parallelaccelerator/pamaster.conf
echo PAMASTER_ADDR=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1):8800 >> /etc/parallelaccelerator/pamaster.conf
echo PARALLELS_PER_WORKER=${parallels_per_worker} >> /etc/parallelaccelerator/pamaster.conf
echo SEND_BATCH_SIZE=${send_batch_size} >> /etc/parallelaccelerator/pamaster.conf
echo RECURSION_THREAD_NUM=${recursion_thread_num} >> /etc/parallelaccelerator/pamaster.conf
echo PREFIX_LEVELS_USE_DELIMITER=${prefix_levels_use_delimiter} >> /etc/parallelaccelerator/pamaster.conf
echo PPERF_ADDR=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1):8801 >> /etc/parallelaccelerator/pamaster.conf
echo ETCD=${etcd} >> /etc/parallelaccelerator/pamaster.conf
echo FILESYSTEMS=${filesystems} >> /etc/parallelaccelerator/pamaster.conf

cat << EOF > /lib/systemd/system/pamaster.service
[Unit]
Description=ParallelAccelerator Master
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/pamaster

[Service]
EnvironmentFile=/etc/parallelaccelerator/pamaster.conf
ExecStart=/usr/local/bin/pamaster \\
    --cluster_name \${CLUSTER_NAME} \\
    --inst_id \${INST_ID} \\
    --addr \${PAMASTER_ADDR} \\
    --perf_addr \${PPERF_ADDR} \\
    --parallels_per_worker \${PARALLELS_PER_WORKER} \\
    --send_batch_size \${SEND_BATCH_SIZE} \\
    --recursion_thread_num \${RECURSION_THREAD_NUM} \\
    --prefix_levels_use_delimiter \${PREFIX_LEVELS_USE_DELIMITER} \\
    --etcd_endpoints \${ETCD} \\
    --filesystems \${FILESYSTEMS}

Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=1048576

# Specifies the maximum number of threads this process can create
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable pamaster
systemctl start pamaster.service
systemctl status -l pamaster.service
