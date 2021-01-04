#!/bin/bash
#给目录授权
export HADOOP_USER_NAME=hdfs
hdfs dfs -chmod -R 777 /tmp/ck_test
#将数据从集群1的active状态的hdfs namenode 发送到集群2的active状态的hdfs namenode
hadoop distcp -update -skipcrccheck hdfs://active_host_ip1:8020/hive表文件路径/* hdfs://active_host_ip2:8020/hive表文件路径/