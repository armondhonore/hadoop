FROM mirror.gcr.io/library/alpine:3.19 AS fetch
RUN apk add --no-cache wget ca-certificates
ARG VERSION=3.3.6
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-${VERSION}/hadoop-${VERSION}.tar.gz -O /tmp/hadoop.tar.gz

FROM mirror.gcr.io/library/eclipse-temurin:11-jre-alpine
WORKDIR /opt/hadoop
COPY --from=fetch /tmp/hadoop.tar.gz /tmp/
RUN tar -xzf /tmp/hadoop.tar.gz -C /opt --strip-components=1 && rm /tmp/hadoop.tar.gz

# Ensure necessary shell tools are present
RUN apk add --no-cache bash

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8088 9000 9864 8042 8032

USER root
RUN printf '%s\n' \
    '#!/bin/sh' \
    'if [ -n "$ROOT_URL" ]; then' \
    '  _h=$(echo "$ROOT_URL" | sed "s|https://||" | sed "s|\.cloud\.nexlayer\.ai||")' \
    '  _d=$(echo "$_h" | cut -d- -f3-)' \
    '  export HDFS_NAMENODE_ADDRESS="${_d}-namenode-service:9000"' \
    '  export YARN_RESOURCEMANAGER_ADDRESS="${_d}-resourcemanager-service:8032"' \
    'fi' \
    'exec "$@"' > /nx-start.sh && chmod +x /nx-start.sh

ENTRYPOINT ["/bin/sh", "/nx-start.sh", "/entrypoint.sh"]
