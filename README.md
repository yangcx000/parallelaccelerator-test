# 部署安装
## 1. machines目录下填写需要部署的服务机器IP
格式为: {env}-masters/workers.txt

如：test-vocles-lf-masters.txt/test-vocles-lf-workers.txt

## 2. 部署ETCD集群
略。

## 3. 部署pamaster/paworker服务
### 3.1 部署pamaster
```bash
sh installer.sh [test-vocles-lf] [pamaster] [test-vocles-lf] [etcd_endpoints] [pfs-vocles:/mnt/vepfs]
```

### 3.2 部署paworker
```bash
sh installer.sh [test-vocles-lf] [paworker] [test-vocles-lf] [etcd_endpoints] [pfs-vocles:/mnt/vepfs]
```

## 4. 查看服务状态
```bash
systemctl status -l pamaster
systemctl status -l paworker@{7000..7001}
```

# 提交加速任务
## 1. conf目录下创建源和目标yaml文件
见目录下Samples。

## 2. 创建TOS至PFS加速任务
```bash
cmd/dataflow/dataflow -c conf/tos-to-pfs.yaml -t acceleration -o create -s {pamaster_ip}:8800
```

## 3. 查看任务状态
### 3.1 查看所有运行中任务
```bash
cmd/dataflow/dataflow -t acceleration -o list -s {pamaster_ip}:8800 -st running
```

### 3.2 查看单个任务状态
```bash
cmd/dataflow/dataflow -t acceleration -o query -j {jobid} -s {pamaster_ip}:8800
```

### 3.3 取消任务
```bash
cmd/dataflow/dataflow -t acceleration -o delete -j {jobid} -s {pamaster_ip}:8800
```
