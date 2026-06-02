FROM apache/hadoop:3

USER root

# Pass-through: each pod overrides CMD with the daemon to start,
# e.g. CMD ["hdfs", "namenode"] or CMD ["yarn", "resourcemanager"].
# Namenode formats storage on first boot before starting.
RUN printf '#!/bin/bash\nset -e\nif [[ "$1 $2" == "hdfs namenode" ]] && [ ! -d /tmp/hadoop-root/dfs/name/current ]; then\n  hdfs namenode -format -nonInteractive\nfi\nexec "$@"\n' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 9870 9864 8088 8042

ENTRYPOINT ["/entrypoint.sh"]
