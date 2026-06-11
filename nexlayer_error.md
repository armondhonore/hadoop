# Nexlayer Build Failure Report

**Pipeline:** 19eb477c8ff
**Repository:** https://github.com/armondhonore/hadoop
**Error category:** dockerfile_syntax
**Error summary:** Dockerfile syntax error on line 21: '_h=$(echo' is not a valid instruction.

## Build log
```
error building image: parsing dockerfile: dockerfile parse error on line 21: unknown instruction: _h=$(echo
```

## Repository build artifacts

These are the actual files from the repository. Use these to understand how the project
is SUPPOSED to be built — do not rely solely on the broken Dockerfile below.


### pom.xml
```
<?xml version="1.0" encoding="UTF-8"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->
<project xmlns="http://maven.apache.org/POM/4.0.0"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>org.apache.hadoop</groupId>
  <artifactId>hadoop-main</artifactId>
  <version>3.6.0-SNAPSHOT</version>
  <description>Apache Hadoop Main</description>
  <name>Apache Hadoop Main</name>
  <packaging>pom</packaging>

  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>com.cenqua.clover</groupId>
        <artifactId>clover</artifactId>
        <!-- Use the version needed by maven-clover-plugin -->
        <version>3.0.2</version>
      </dependency>
    </dependencies>
  </dependencyManagement>

  <distributionManagement>
    <repository>
      <id>${distMgmtStagingId}</id>
      <name>${distMgmtStagingName}</name>
      <url>${distMgmtStagingUrl}</url>
    </repository>
    <snapshotRepository>
      <id>${distMgmtSnapshotsId}</id>
      <name>${distMgmtSnapshotsName}</name>
      <url>${distMgmtSnapshotsUrl}</url>
    </snapshotRepository>
    <site>
      <id>apache.website</id>
      <url>scpexe://people.apache.org/www/hadoop.apache.org/docs/r${project.version}</url>
    </site>
  </distributionManagement>

  <repositories>
    <repository>
      <id>${distMgmtSnapshotsId}</id>
   
... (truncated)
```


## Last attempted Dockerfile
```dockerfile
FROM mirror.gcr.io/library/alpine:3.19 AS fetch
RUN apk add --no-cache wget ca-certificates
ARG VERSION=3.3.6
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-${VERSION}/hadoop-${VERSION}.tar.gz -O /tmp/hadoop.tar.gz

FROM mirror.gcr.io/library/eclipse-temurin:11-jre-alpine
WORKDIR /opt/hadoop
COPY --from=fetch /tmp/hadoop.tar.gz /tmp/
RUN tar -xzf /tmp/hadoop.tar.gz -C /opt --strip-components=1 && rm /tmp/hadoop.tar.gz

RUN apk add --no-cache bash

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8088 9000 9864 8042 8032

USER root
RUN echo '#!/bin/sh
if [ -n "$ROOT_URL" ]; then
  _h=$(echo "$ROOT_URL" | sed "s|https://||" | sed "s|\.cloud\.nexlayer\.ai||")
  _d=$(echo "$_h" | cut -d- -f3-)
  export HDFS_NAMENODE_ADDRESS="${_d}-namenode-service:9000"
  export YARN_RESOURCEMANAGER_ADDRESS="${_d}-resourcemanager-service:8032"
fi
exec "$@"
' > /nx-start.sh && chmod +x /nx-start.sh

ENTRYPOINT ["/bin/sh", "/nx-start.sh", "/entrypoint.sh"]
```

## Last attempted nexlayer.yaml
```yaml
application:
  name: hadoop
  pods:
    - name: namenode
      image: "# filled by pipeline"
      servicePorts:
        - 9000
        - 9870
      vars:
        HADOOP_ROLE: "namenode"
    - name: datanode
      image: "# filled by pipeline"
      servicePorts:
        - 9864
      vars:
        HADOOP_ROLE: "datanode"
    - name: resourcemanager
      image: "# filled by pipeline"
      servicePorts:
        - 8088
        - 8032
      vars:
        HADOOP_ROLE: "resourcemanager"
    - name: nodemanager
      image: "# filled by pipeline"
      servicePorts:
        - 8042
      vars:
        HADOOP_ROLE: "nodemanager"
```

## Instructions for frontier model

CRITICAL: Before writing any fix, read the repository build artifacts above and answer:
1. What language/runtime does this project use? (go.mod, package.json, pom.xml, Cargo.toml, requirements.txt)
2. What is the actual build command? (package.json scripts.build, Makefile targets, pom.xml goals, gradle tasks)
3. What is the actual start command? (package.json scripts.start, Makefile run target, Procfile)
4. What port does it serve? (EXPOSE, ENV PORT=, --port flag, framework default)
5. What dependencies does it need at runtime? (docker-compose.yml services, .env.example vars)

Then create a correct Dockerfile from scratch based on your analysis:
- All FROM base images must be standard public images (library/, gcr.io, ghcr.io, etc.)
- Use `mirror.gcr.io/library/` prefix for Docker Hub official images (node:*, python:*, golang:*, etc.)
- DO NOT copy broken steps from the "last attempted Dockerfile" — build from what the repo actually needs

Fix nexlayer.yaml if needed:
- Inter-pod service references MUST use `${podName:port}` template syntax
- Example: `DATABASE_URL: postgresql://user:pass@${postgres:5432}/db`

Create a file named `nexlayer_fix.md` on THIS branch (`nexlayer`) with this structure:

---
# Nexlayer Fix

## Fixed Dockerfile
```dockerfile
<your fixed Dockerfile>
```

## Fixed nexlayer.yaml
```yaml
<your fixed nexlayer.yaml>
```

## Notes
<explain: what build command you found, what was wrong with the previous Dockerfile, what you changed and why>
---

Nexlayer detects `nexlayer_fix.md` on the next pipeline run and applies your fixes automatically.
