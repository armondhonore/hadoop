#!/bin/sh
set -e
HADOOP_CONF_DIR="${HADOOP_HOME}/etc/hadoop"
ROLE="${HADOOP_ROLE:-namenode}"

mkdir -p /data/namenode /data/datanode

# Nexlayer platform sets pod spec.hostname=<podName>, spec.subdomain=pod.
# Headless service "pod" (ClusterIP:None) in the namespace resolves <podName>.pod
# to the pod IP directly — bypasses service port filtering, all ports reachable.
# namenode.pod:9000   = NameNode RPC (IPC port)
# resourcemanager.pod = ResourceManager, ports 8032/8030/8031

cat > "${HADOOP_CONF_DIR}/core-site.xml" <<XMLEOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property><name>fs.defaultFS</name><value>hdfs://namenode.pod:9000</value></property>
</configuration>
XMLEOF

cat > "${HADOOP_CONF_DIR}/hdfs-site.xml" <<XMLEOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property><name>dfs.namenode.rpc-address</name><value>0.0.0.0:9000</value></property>
  <property><name>dfs.namenode.http-address</name><value>0.0.0.0:9870</value></property>
  <property><name>dfs.datanode.address</name><value>0.0.0.0:9866</value></property>
  <property><name>dfs.datanode.http.address</name><value>0.0.0.0:9864</value></property>
  <property><name>dfs.namenode.name.dir</name><value>file:///data/namenode</value></property>
  <property><name>dfs.datanode.data.dir</name><value>file:///data/datanode</value></property>
  <property><name>dfs.replication</name><value>1</value></property>
  <property><name>dfs.permissions.enabled</name><value>false</value></property>
</configuration>
XMLEOF

cat > "${HADOOP_CONF_DIR}/yarn-site.xml" <<XMLEOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property><name>yarn.resourcemanager.hostname</name><value>resourcemanager.pod</value></property>
  <property><name>yarn.resourcemanager.address</name><value>resourcemanager.pod:8032</value></property>
  <property><name>yarn.resourcemanager.scheduler.address</name><value>resourcemanager.pod:8030</value></property>
  <property><name>yarn.resourcemanager.resource-tracker.address</name><value>resourcemanager.pod:8031</value></property>
  <property><name>yarn.nodemanager.aux-services</name><value>mapreduce_shuffle</value></property>
  <property><name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name><value>org.apache.hadoop.mapred.ShuffleHandler</value></property>
  <property><name>yarn.nodemanager.resource.memory-mb</name><value>1024</value></property>
  <property><name>yarn.scheduler.minimum-allocation-mb</name><value>256</value></property>
</configuration>
XMLEOF

cat > "${HADOOP_CONF_DIR}/mapred-site.xml" <<XMLEOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property><name>mapreduce.framework.name</name><value>yarn</value></property>
</configuration>
XMLEOF

echo "Config written: role=${ROLE}, namenode=namenode.pod:9000, rm=resourcemanager.pod:8032"

case "${ROLE}" in
  namenode)
    # Only format on first start (avoid losing data on restarts)
    if [ ! -d /data/namenode/current ]; then
        hdfs namenode -format -force
    fi
    exec hdfs namenode
    ;;
  datanode) exec hdfs datanode;;
  resourcemanager) exec yarn resourcemanager;;
  nodemanager) exec yarn nodemanager;;
  *) exec "$@";;
esac
