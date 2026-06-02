FROM apache/hadoop:3

USER root

# Start all four daemons in one container. Format NameNode on first boot.
RUN printf '#!/bin/bash\nset -e\nif [ ! -d /tmp/hadoop-root/dfs/name/current ]; then\n  hdfs namenode -format -nonInteractive\nfi\nhdfs namenode &\nhdfs datanode &\nyarn resourcemanager &\nyarn nodemanager &\nwait -n\n' > /start.sh && chmod +x /start.sh

EXPOSE 8088

CMD ["/start.sh"]
