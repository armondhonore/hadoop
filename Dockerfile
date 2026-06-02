FROM apache/hadoop:3

USER root

# Single-node pseudo-distributed startup script.
# Formats the NameNode on first boot, then starts all four daemons.
RUN printf '#!/bin/bash\nset -e\nif [ ! -d /tmp/hadoop-root/dfs/name/current ]; then\n  hdfs namenode -format -nonInteractive\nfi\nhdfs namenode &\nhdfs datanode &\nyarn resourcemanager &\nyarn nodemanager &\nwait -n\n' > /start.sh && chmod +x /start.sh

EXPOSE 8088 9870

CMD ["/start.sh"]
