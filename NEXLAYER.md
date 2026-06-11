# Nexlayer — hadoop

<!-- nexlayer:meta version=1 analyzed=2026-06-11T02:17:13Z repo=https://github.com/armondhonore/hadoop branch=trunk -->

> **For AI agents (Claude Code, Cursor, Gemini CLI, Copilot):**
> This file is the **project context** for this Nexlayer deployment — tech stack, env vars, secrets, live URL.
> For full platform detail (nexlayer.yaml schema, Dockerfile rules, CI/CD, task recipes) read **`nexlayer.skills`** in this repo.
>
> **Critical rules (full detail in `nexlayer.skills`):**
> - Inter-pod refs: `${podName:port}` only — never `localhost` or bare hostnames
> - Docker Hub images: prefix with `mirror.gcr.io/library/` — bare tags fail on the cluster
> - Secrets: set in the Nexlayer dashboard — never commit to `nexlayer.yaml` or Dockerfile
>
> **This file:** `agent-managed` sections update automatically. `user-editable` sections (Local Development Setup, Nexlayer Deployment Plan, Build Notes) are yours — preserved across re-analysis.

## Project Summary
<!-- nexlayer:section agent-managed=project_summary -->
Apache Hadoop is a framework that allows for the distributed processing of large data sets across clusters of computers using simple programming models.
<!-- nexlayer:end -->

## Technology Stack
<!-- nexlayer:section agent-managed=tech_stack -->
| Name | Kind | Version | Detected From |
|------|------|---------|---------------|
| Java | language | 11 | Dockerfile |
| Apache Hadoop | infra | 3.6.0-SNAPSHOT | pom.xml |
| Maven | build | unknown | pom.xml, mvnw |
<!-- nexlayer:end -->

## Repository Structure
<!-- nexlayer:section agent-managed=structure_map -->
- hadoop-hdfs-project/ — Distributed file system implementation
- hadoop-yarn-project/ — Resource management and job scheduling
- hadoop-mapreduce-project/ — MapReduce processing framework
- hadoop-common-project/ — Common utilities and abstractions
<!-- nexlayer:end -->

## External Services Required
<!-- nexlayer:section agent-managed=external_deps -->
_No external services detected._
<!-- nexlayer:end -->

## Local Development Setup
<!-- nexlayer:section user-editable=local_setup -->
### Prerequisites

- JDK 11
- Apache Maven 3.8+

### Environment variables

Copy `.env.example` to `.env.local` and fill in:

```
HADOOP_HOME=/opt/hadoop
JAVA_HOME=/usr/lib/jvm/java-11-openjdk
```

### Steps

1. `./mvnw clean install -DskipTests` — Build Hadoop binaries using the Maven wrapper
2. `hdfs namenode -format` — Format the NameNode before first run
3. `start-all.sh` — Start HDFS and YARN daemons

<!-- nexlayer:end -->

## Nexlayer Setup
<!-- nexlayer:section agent-managed=nexlayer_setup -->
### Pod Environment Variables

| Pod | Variable | Value | Kind |
|-----|----------|-------|------|
| `namenode` | `HADOOP_ROLE` | `"namenode"` | plain |
| `datanode` | `HADOOP_ROLE` | `"datanode"` | plain |
| `resourcemanager` | `HADOOP_ROLE` | `"resourcemanager"` | plain |
| `nodemanager` | `HADOOP_ROLE` | `"nodemanager"` | plain |

### nexlayer.yaml

```yaml
application:
  name: slim-lake-hadoop
  pods:
    - name: namenode
      image: "# filled by pipeline"
      servicePorts:
        - 9000
        - 9864
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

<!-- nexlayer:end -->

## Nexlayer Deployment Plan
<!-- nexlayer:section user-editable=deployment_plan -->
### Pod Topology

| Pod | Image | Port | Role |
|-----|-------|------|------|
| namenode | mirror.gcr.io/library/openjdk:11-slim | 9870 | namenode |
| datanode | mirror.gcr.io/library/openjdk:11-slim | 9864 | datanode |
| resourcemanager | mirror.gcr.io/library/openjdk:11-slim | 8088 | scheduler |
| nodemanager | mirror.gcr.io/library/openjdk:11-slim | 8042 | worker |

### Inter-pod environment variables

- `datanode` pod: `FS_DEFAULTFS=${namenode:9870}`
- `resourcemanager` pod: `YARN_CONF_yarn_resourcemanager_hostname=${resourcemanager:8088}`
- `nodemanager` pod: `YARN_CONF_yarn_resourcemanager_address=${resourcemanager:8088}`

### Deployment notes

- Decomposed the pseudo-distributed Dockerfile into a multi-pod topology per Nexlayer Rule 1 and 5.
- Used mirror.gcr.io/library/openjdk:11-slim as base image per Nexlayer Rule 3 for Apache systems.
- Inter-pod communication established using ${podName:port} syntax for NameNode and ResourceManager references.

<!-- nexlayer:end -->

## Build Notes
<!-- nexlayer:section user-editable=build_notes -->
<!-- Add notes for future builds here — preserved across re-analysis -->
<!-- nexlayer:end -->

## Nexlayer Configuration
<!-- nexlayer:section agent-managed=nexlayer_config -->
**Last deployed:** 2026-06-11T02:48:03Z  
**Live URL:** https://slim-lake-hadoop.nexlayer.ai  
**Runtime:** java · **Port:** 8088  
**Deploy branch:** trunk  

```yaml
application:
  name: slim-lake-hadoop
  pods:
    - name: namenode
      image: "# filled by pipeline"
      servicePorts:
        - 9000
        - 9864
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
<!-- nexlayer:end -->

## Build History
<!-- nexlayer:section agent-managed=build_history -->
| Date | Status | Notes |
|------|--------|-------|
| 2026-06-11T02:17:13Z | analyzed | initial repo analysis |
| 2026-06-11T02:48:03Z | success | deployed https://slim-lake-hadoop.nexlayer.ai |
<!-- nexlayer:end -->
