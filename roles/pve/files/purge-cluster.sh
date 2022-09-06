#!/bin/bash
#重新初始化pve系统,清理集群.
#只有当某个pve节点在集群中状态异常、pve集群需要重做时才可以执行，谨慎执行
# 执行脚本会清理当前pve节点所有集群信息
echo -e "stopping Services:\npvestatd"
systemctl stop pvestatd.service
echo "pvedaemon"
systemctl stop pvedaemon.service
echo "pve-cluster.service"
systemctl stop pve-cluster.service
echo "pve-corosync"
systemctl stop corosync
echo "pve-cluster"
systemctl stop pve-cluster
echo "deleting data from db..."
#echo "select * from tree where name = 'corosync.conf';"| sqlite3 /var/lib/pve-cluster/config.db
echo "delete from tree where name = 'corosync.conf';" | sqlite3 /var/lib/pve-cluster/config.db
echo "select * from tree where name = 'corosync.conf';" | sqlite3 /var/lib/pve-cluster/config.db
#Remove directories
pmxcfs -l
rm -rf /var/lib/pve-cluster/.pmxcfs.lockfile
rm -rf /etc/pve/corosync.conf
rm -rf /etc/corosync/*
rm -rf /var/lib/corosync/*
rm -rf /etc/pve/nodes/*
echo "Staring services ..."
echo "pvestatd"
systemctl start pvestatd.service
echo "pvedaemon"
systemctl start pvedaemon.service
echo "pve-cluster.service"
systemctl start pve-cluster.service
echo "pve-corosync"
systemctl start corosync
echo "pve-cluster"
systemctl restart pve-cluster