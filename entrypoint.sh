#!/bin/sh
set -e
HADOOP_CONF_DIR="${HADOOP_HOME}/etc/hadoop"

# Generate core-site.xml — HDFS_NAMENODE_ADDRESS is injected by Nexlayer platform
NAMENODE_ADDR="${HDFS_NAMENODE_ADDRESS:-localhost:9000}"
cat > "${HADOOP_CONF_DIR}/core-site.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property><name>fs.defaultFS</name><value>hdfs://${NAMENODE_ADDR}</value></property>
</configuration>
EOF

# Generate hdfs-site.xml
mkdir -p /data/namenode /data/datanode
cat > "${HADOOP_CONF_DIR}/hdfs-site.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property><name>dfs.namenode.name.dir</name><value>file:///data/namenode</value></property>
  <property><name>dfs.datanode.data.dir</name><value>file:///data/datanode</value></property>
  <property><name>dfs.replication</name><value>1</value></property>
</configuration>
EOF

# Generate yarn-site.xml — YARN_RESOURCEMANAGER_ADDRESS injected by Nexlayer
RM_ADDR="${YARN_RESOURCEMANAGER_ADDRESS:-localhost:8032}"
RM_HOST=$(echo "$RM_ADDR" | cut -d: -f1)
cat > "${HADOOP_CONF_DIR}/yarn-site.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property><name>yarn.resourcemanager.hostname</name><value>${RM_HOST}</value></property>
  <property><name>yarn.nodemanager.aux-services</name><value>mapreduce_shuffle</value></property>
  <property><name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name><value>org.apache.hadoop.mapred.ShuffleHandler</value></property>
</configuration>
EOF

# Generate mapred-site.xml
cat > "${HADOOP_CONF_DIR}/mapred-site.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property><name>mapreduce.framework.name</name><value>yarn</value></property>
  <property><name>mapreduce.application.classpath</name><value>\$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*:\$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value></property>
</configuration>
EOF

echo "Config written for role=${HADOOP_ROLE}, namenode=${NAMENODE_ADDR}, rm=${RM_ADDR}"

case "${HADOOP_ROLE}" in
  namenode)
    hdfs namenode -format -force 2>/dev/null || true
    exec hdfs namenode
    ;;
  datanode)
    exec hdfs datanode
    ;;
  resourcemanager)
    exec yarn resourcemanager
    ;;
  nodemanager)
    exec yarn nodemanager
    ;;
  *)
    exec "$@"
    ;;
esac
