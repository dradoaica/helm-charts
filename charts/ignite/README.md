# ignite

![Version: 2.19.4](https://img.shields.io/badge/Version-2.19.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.19.0](https://img.shields.io/badge/AppVersion-2.19.0-informational?style=flat-square)

Apache Ignite is a distributed database for high-performance computing with in-memory speed.

**Homepage:** <https://ignite.apache.org/docs/ignite2/latest/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| dradoaica | <dradoaica@gmail.com> | <https://dradoaica.blogspot.com/> |

## Source Code

* <https://github.com/apache/ignite>

## Requirements

Kubernetes: `>= 1.26.0`

## Images

Until Apache Ignite 2.19.0 (`appVersion`) is released, set `image.tag` to `2.18.0`.

## Upgrading from 2.19.3

Upgrade with `--reset-then-reuse-values`, as from 2.19.2 (the chart fails with a message on values that miss the new
settings):

```shell
helm upgrade <release> <chart> --version 2.19.4 --reset-then-reuse-values
```

- The default `networkPolicy.egress` allows the Kubernetes API server on port 16443 too (MicroK8s, where the nodes did
  not find each other).
- The autoscaler (`autoscaling.create`) only scales up, on CPU only (`autoscaling.targetMemoryUtilizationPercentage` is
  refused), with `autoscaling.minReplicas` not below `replicaCount`; it is refused with `persistence.enabled`, as the
  added pods would hold no data.

## Upgrading from 2.19.2

Upgrade with `--reset-then-reuse-values` (not `--reuse-values`, which keeps the 2.19.2 defaults and misses the new
settings; the chart then fails with a message):

```shell
helm upgrade <release> <chart> --version 2.19.3 --reset-then-reuse-values
```

- The containers run with a read-only root filesystem, with writable `emptyDir` volumes for `/tmp` and the work
  directory `/opt/ignite/apache-ignite/work` (the logs and, without persistence, the work data). `EXTERNAL_LIBS` in
  `env`, which the image downloads into its libs directory, requires `containerSecurityContext.readOnlyRootFilesystem`
  set to false.
- The logs also go to the console (`kubectl logs`), without ANSI colors (`logging.console`, `logging.level`); the work
  directory keeps the last `logging.maxRolledFiles` rolled log files, instead of all of them.
- The activation job runs with the chart's security contexts (restricted Pod Security Standard), and its checks of the
  REST responses no longer take a failed response for a successful one.
- `podDisruptionBudget.minAvailable`, when set, is used instead of `maxUnavailable` (setting both was refused);
  `revisionHistoryLimit` can be 0, and `kubectl exec` defaults to the `ignite-node` container.

## Upgrading from 2.18.x

Nodes of different Ignite minor versions cannot form one cluster (2.19 nodes do not even recognize 2.18 ones), so the
chart refuses to replace running pods with pods of another minor version. Chart 2.18.3 and earlier also kept the work
directory (binary metadata, marshaller mappings, snapshots) out of the storage volume, so data stored as binary objects
(e.g., SQL rows) could not be read after the whole cluster had restarted. With persistence, upgrade in two steps:

1. Move the work directory to the storage volume, still on Ignite 2.18 (not needed from chart 2.18.4): the pods restart
   one by one and receive the metadata from the others. A single node has no others, so copy its metadata first:

   ```shell
   kubectl exec <release>-ignite-cluster-0 -- sh -c 'mkdir -p /storage/work && cp -r /opt/ignite/apache-ignite/work/db /storage/work/'
   helm upgrade <release> <chart> --version 2.19.0 --reset-then-reuse-values --set image.tag=2.18.0
   ```

2. Stop the cluster and start it on Ignite 2.19 (the activation job activates it again):

   ```shell
   kubectl exec -it <release>-ignite-cluster-0 -- /opt/ignite/apache-ignite/bin/control.sh --set-state INACTIVE
   kubectl scale statefulset <release>-ignite-cluster --replicas=0
   helm upgrade <release> <chart> --version 2.19.0 --reset-then-reuse-values --set image.tag=2.19.0
   ```

Without persistence, only the second step applies (without the deactivation). Values that Ignite 2.19 no longer
supports (memoryConfiguration, tracing) make the chart fail with a message.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| activationJob.activeDeadlineSeconds | int | `1800` | Maximum duration of the job in seconds (it waits for every pod) |
| activationJob.enabled | bool | `true` | Enable the cluster activation job |
| activationJob.image | object | `{"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"curlimages/curl","tag":"8.17.0"}` | Image for the cluster activation job |
| activationJob.resources | object | `{"limits":{"cpu":"100m","memory":"128Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | Resources for the cluster activation job |
| affinity | object | `{}` | Node affinity |
| annotations | object | `{}` | Annotations to add to all resources |
| authentication.enabled | bool | `true` | Enable authentication (requires persistence.enabled, as Ignite keeps the users in its persistent metastorage) |
| authentication.existingSecret | object | `{"key":"","name":"","previousKey":""}` | Use an existing Secret for the ignite user password instead of a chart-managed Secret |
| authentication.existingSecret.key | string | `""` | Key in the existing Secret that holds the password (defaults to 'ignite-user-password') |
| authentication.existingSecret.name | string | `""` | Name of the existing Secret containing the ignite user password |
| authentication.existingSecret.previousKey | string | `""` | Key in the existing Secret that holds the previous password (defaults to 'ignite-user-previous-password'; optional) |
| authentication.igniteUserPassword | string | `""` | Password for the ignite user, set by the activation job (defaults to ignite when empty) |
| authentication.igniteUserPreviousPassword | string | `""` | Current password of the ignite user, when rotating it to igniteUserPassword |
| authentication.manageSecret | bool | `true` | When true (default), the chart may create/manage its own Secret from values when no existingSecret is specified |
| autoscaling.create | bool | `false` | Create a HorizontalPodAutoscaler that only scales up, only without persistence.enabled - see the values.yaml comments |
| autoscaling.maxReplicas | int | `10` | Maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas (not below replicaCount) |
| autoscaling.scaleUp | object | `{"policies":[{"periodSeconds":600,"type":"Pods","value":1}],"stabilizationWindowSeconds":600}` | Scale-up behavior (by default, one pod every 10 minutes, as every added node triggers rebalancing) |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage |
| binaryConfiguration | string | `""` | Binary configuration |
| cacheConfiguration | string | `""` | Cache configuration |
| cacheKeyConfiguration | string | `""` | Cache key configuration |
| clientConnector | object | `{"extraConfiguration":""}` | Client connector configuration |
| clientConnector.extraConfiguration | string | `""` | Extra configuration for org.apache.ignite.configuration.ClientConnectorConfiguration bean |
| collisionSpi | string | `""` | Collision SPI |
| communicationSpi | string | `"<bean class=\"org.apache.ignite.spi.communication.tcp.TcpCommunicationSpi\">\n    <property name=\"messageQueueLimit\" value=\"2048\"/>\n    <property name=\"slowClientQueueLimit\" value=\"2048\"/>\n    <property name=\"socketWriteTimeout\" value=\"5000\"/>\n    <property name=\"connectTimeout\" value=\"10000\"/>\n</bean>"` | Communication SPI |
| container.ports | object | `{"jdbc":11211,"metrics":9464,"rest":8080,"spiCommunication":47100,"spiDiscovery":47500,"sql":10800}` | Container ports used by the Pod spec and as Service targetPort values |
| container.ports.jdbc | int | `11211` | TCP binary protocol of the REST connector (e.g., the legacy JDBC driver) |
| container.ports.metrics | int | `9464` | Prometheus metrics (only with metrics.enabled) |
| container.ports.rest | int | `8080` | REST API (unencrypted) |
| container.ports.sql | int | `10800` | Thin clients, JDBC, ODBC and the control utility (client connector) |
| containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}}` | Container security context configuration |
| containerSecurityContext.enabled | bool | `true` | Enable container security context |
| dataStorage | object | `{"extraConfiguration":"","pageEvictionMode":""}` | Data storage configuration |
| dataStorage.extraConfiguration | string | `""` | Extra configuration for org.apache.ignite.configuration.DataStorageConfiguration bean |
| dataStorage.pageEvictionMode | string | `""` | Off-heap eviction policy for in-memory mode (DISABLED, RANDOM_LRU or RANDOM_2_LRU; ignored with persistence) |
| deploymentSpi | string | `""` | Deployment SPI (deprecated since Ignite 2.19) |
| encryptionSpi | string | `""` | Encryption SPI |
| env | object | `{"EXTRA_JVM_OPTS":"","EXTRA_OPTION_LIBS":""}` | Environment variables |
| env.EXTRA_JVM_OPTS | string | `""` | Extra JVM options, separated by spaces |
| env.EXTRA_OPTION_LIBS | string | `""` | Extra Ignite optional libraries (OPTION_LIBS), separated by commas |
| executorConfiguration | string | `""` | Executor configuration |
| extraBeans | string | `""` | Extra beans (e.g., com.mysql.cj.jdbc.MysqlDataSource) |
| extraContainers | list | `[]` | Extra sidecar containers to inject into the main Pod spec |
| extraEnvFrom | list | `[]` | Extra envFrom entries to inject into the main container |
| extraEnvVars | list | `[]` | Extra environment variables to inject into the main container |
| extraEnvVarsCM | string | `""` | Name of a ConfigMap with extra environment variables to inject into the main container |
| extraEnvVarsSecret | string | `""` | Name of a Secret with extra environment variables to inject into the main container |
| extraInitContainers | list | `[]` | Extra init containers to inject into the main Pod spec |
| extraVolumeMounts | list | `[]` | Extra volume mounts to add to the main container |
| extraVolumes | list | `[]` | Extra volumes to add to the main Pod spec |
| failoverSpi | string | `""` | Failover SPI |
| fullnameOverride | string | `""` | String to fully override the fullname template with a string |
| global.imagePullSecrets | list | `[]` | Global pod image pull secrets |
| global.imageRegistry | string | `""` | Global container image registry override |
| image.pullPolicy | string | `"IfNotPresent"` | Main container image pull policy |
| image.registry | string | `"docker.io"` | Main container image registry |
| image.repository | string | `"apacheignite/ignite"` | Main container image repository |
| image.tag | string | `""` | Main container image tag (defaults to appVersion when empty; each architecture has its own tag, e.g., 2.19.0-arm64) |
| ingress.annotations | object | `{}` | Additional annotations for the Ingress |
| ingress.className | string | `""` | IngressClass that will be used to implement the Ingress |
| ingress.create | bool | `false` | Create an Ingress for external HTTP access to REST API |
| ingress.hosts | list | `[{"host":"ignite.local","paths":[{"path":"/","pathType":"Prefix","port":8080}]}]` | List of Ingress hosts with path configuration |
| ingress.tls | list | `[]` | TLS configuration for Ingress |
| labels | object | `{}` | Additional labels to add to all resources |
| lifecycleHooks | object | `{}` | Lifecycle hooks configuration |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/ignite?cmd=version","port":8080},"initialDelaySeconds":5,"periodSeconds":30,"successThreshold":1,"timeoutSeconds":10}` | Liveness probe configuration |
| livenessProbe.enabled | bool | `true` | Enable liveness probe |
| loadBalancingSpi | string | `""` | Load balancing SPI |
| logging.console | bool | `true` | Log to the console (kubectl logs) too; when false, only the errors (the logs are always kept in the work directory) |
| logging.level | string | `"INFO"` | Root log level (e.g., INFO, DEBUG) |
| logging.maxRolledFiles | int | `10` | Number of rolled (compressed) log files kept in the work directory |
| memory.g1HeapRegionSizeMB | string | `""` | JVM G1 Heap region size in MB (a power of 2 from 1 to 32). If not set, the JVM chooses (about 2048 regions; 1 MB for the default heap) |
| memory.maxDirectMemorySizeMB | int | `2960` | JVM DirectMemory max size in MB (offHeapMB + checkpointing buffer size + other system regions total size) |
| memory.maxMetaspaceSizeMB | string | `""` | JVM Metaspace max size in MB. If not set, defaults to 256 |
| memory.offHeapMB | int | `2048` | Off-heap memory limit in MB. Configures the default data region max size (data + indexes) |
| memory.onHeapMB | string | `""` | On-heap memory limit in MB (the JVM heap; -Xms and -Xmx). If not set, defaults to 1024 |
| memory.reservedCodeCacheSizeMB | string | `""` | JVM ReservedCodeCache size in MB. If not set, defaults to 240 |
| metrics.enabled | bool | `false` | Enable metrics, exposed for Prometheus on container.ports.metrics (/metrics, with the prometheus.io pod annotations) |
| minReadySeconds | int | `60` | Seconds a started pod must stay ready before the next one starts or restarts (Ignite's readiness probe does not wait for rebalancing; raise it for large data sets) |
| nameOverride | string | `""` | String to partially override the fullname template with a string (will prepend the release name) |
| networkPolicy.allowIntraCluster | bool | `true` | Allow ingress/egress traffic between the pods of this release (required for cluster communication) |
| networkPolicy.allowTests | bool | `true` | Allow ingress from the chart's test pods (helm test) |
| networkPolicy.create | bool | `false` | Create a NetworkPolicy |
| networkPolicy.egress | list | `[{"ports":[{"port":53,"protocol":"UDP"},{"port":53,"protocol":"TCP"}],"to":[{"ipBlock":{"cidr":"0.0.0.0/0"}}]},{"ports":[{"port":443,"protocol":"TCP"},{"port":6443,"protocol":"TCP"},{"port":16443,"protocol":"TCP"}],"to":[{"ipBlock":{"cidr":"0.0.0.0/0"}}]}]` | NetworkPolicy egress rules (a list set here replaces these defaults, so repeat the DNS and Kubernetes API server rules in it) |
| networkPolicy.ingress | list | `[]` | NetworkPolicy ingress rules (add rules for clients that need access to the cluster) |
| networkPolicy.name | string | `""` | Name for the NetworkPolicy (defaults to fullname when empty) |
| nodeSelector | object | `{}` | Node selector |
| peerClassLoadingEnabled | bool | `false` | Enable the Ignite's [Zero Deployment](https://ignite.apache.org/docs/ignite2/latest/code-deployment/peer-class-loading.html#enabling-peer-class-loading) |
| persistence.enabled | bool | `true` | Enable persistent settings - both storage and WAL (the work directory, with the binary metadata, marshaller mappings and snapshots, is kept in the storage volume at /storage/work) |
| persistence.persistentVolumeClaimRetentionPolicy.enabled | bool | `false` | Enable persistent volume retention policy |
| persistence.persistentVolumeClaimRetentionPolicy.whenDeleted | string | `"Retain"` | Volume retention behavior that applies when the StatefulSet is deleted |
| persistence.persistentVolumeClaimRetentionPolicy.whenScaled | string | `"Retain"` | Volume retention behavior when the replica count of the StatefulSet is reduced |
| persistence.storageVolume | object | `{"accessModes":["ReadWriteOnce"],"annotations":{},"labels":{},"size":"8Gi","storageClass":""}` | Volume where data and indexes are to be persisted |
| persistence.storageVolume.accessModes | list | `["ReadWriteOnce"]` | Persistent volume access modes |
| persistence.storageVolume.annotations | object | `{}` | Annotations to add to the storage PersistentVolumeClaim |
| persistence.storageVolume.labels | object | `{}` | Labels to add to the storage PersistentVolumeClaim |
| persistence.storageVolume.size | string | `"8Gi"` | Persistent volume size for storage |
| persistence.storageVolume.storageClass | string | `""` | Persistent volume storage class for storage (empty string uses cluster default) |
| persistence.walVolume | object | `{"accessModes":["ReadWriteOnce"],"annotations":{},"labels":{},"size":"8Gi","storageClass":""}` | Volume where WAL is persisted |
| persistence.walVolume.accessModes | list | `["ReadWriteOnce"]` | Persistent volume access modes |
| persistence.walVolume.annotations | object | `{}` | Annotations to add to the WAL PersistentVolumeClaim |
| persistence.walVolume.labels | object | `{}` | Labels to add to the WAL PersistentVolumeClaim |
| persistence.walVolume.size | string | `"8Gi"` | Persistent volume size for WAL |
| persistence.walVolume.storageClass | string | `""` | Persistent volume storage class for WAL (empty string uses cluster default) |
| podAnnotations | object | `{}` | Additional annotations to add to pods |
| podDisruptionBudget.create | bool | `true` | Create a PodDisruptionBudget (only with more than one replica) |
| podDisruptionBudget.maxUnavailable | int | `1` | Maximum number of pods that can be unavailable during disruptions (used when minAvailable is empty) |
| podDisruptionBudget.minAvailable | string | `""` | Minimum number of pods that must be available during disruptions (if set, used instead of maxUnavailable) |
| podLabels | object | `{}` | Additional labels to add to pods |
| podManagementPolicy | string | `"OrderedReady"` | StatefulSet pod management policy |
| podSecurityContext | object | `{"enabled":true,"fsGroup":1001,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001}` | Pod security context configuration |
| podSecurityContext.enabled | bool | `true` | Enable pod security context |
| priorityClassName | string | `""` | Pod priority class name |
| rbac.create | bool | `true` | Create RBAC items (e.g., role, role-binding) |
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/ignite?cmd=probe","port":8080},"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":10}` | Readiness probe configuration |
| readinessProbe.enabled | bool | `true` | Enable readiness probe |
| replicaCount | int | `1` | Number of pods |
| resources | object | `{"limits":{"cpu":"2","memory":"5Gi"},"requests":{"cpu":"2","memory":"5Gi"}}` | Main container requests/limits with guaranteed QoS (requests = limits)  memory calculation: onHeapMB (JVM Heap max size)   + maxMetaspaceSizeMB (JVM Metaspace max size)   + reservedCodeCacheSizeMB (JVM ReservedCodeCache size)   + offHeapMB (default region max size; data + indexes (basic use cases will add a 30% increase on top of data))   + MIN(256MB, offHeapMB) (offHeapMB < 1 GB)     || offHeapMB/4 (offHeapMB between 1 GB and 8 GB)     || 2GB (offHeapMB > 8 GB)       (default region checkpointing buffer size)   + 100MB (sysMemPlc region max size)   + 100MB (metastoreMemPlc region max size)   + 100MB (TxLog region max size)   + 100MB (volatileDsMemPlc region max size)   + ~512MB (other overheads; e.g., thread stacks, GC, symbols, etc.) |
| revisionHistoryLimit | int | `10` | Number of old StatefulSet revisions (ControllerRevisions) to retain |
| service.ports | object | `{"jdbc":11211,"metrics":9464,"rest":8080,"spiCommunication":47100,"spiDiscovery":47500,"sql":10800}` | Service ports used by the Service spec. targetPort fields reference container.ports.* (spiCommunication and spiDiscovery are on the headless Service only) |
| serviceAccount.annotations | object | `{}` | Additional annotations to add to ServiceAccount |
| serviceAccount.create | bool | `true` | Create a dedicated ServiceAccount |
| serviceAccount.name | string | `""` | Name for the ServiceAccount (autogenerated when empty) |
| serviceConfiguration | string | `""` | Service configuration |
| sqlConfiguration | string | `""` | SQL configuration (since Ignite 2.19, SQL runs on the Calcite engine by default, and on H2 only with the QUERY_ENGINE('h2') hint; make org.apache.ignite.indexing.IndexingQueryEngineConfiguration the default engine to keep H2) |
| sqlQueryHistorySize | int | `0` | Number of SQL queries each node keeps in its history (defaults to 0, as the node that ran the activation job's ALTER USER would keep the new password there until restart, readable by every SQL user; empty uses Ignite's default; ignored with sqlConfiguration) |
| ssl | object | `{"clientConnector":{"clientAuth":false,"enabled":false},"enabled":false,"existingSecret":{"keys":{"ksPass":"","tsPass":""},"name":""},"keyAlgorithm":"SunX509","keyStoreFilePath":"","keyStorePassword":"","keyStoreType":"JKS","manageSecret":true,"protocol":"TLSv1.2","trustStoreFilePath":"","trustStorePassword":"","trustStoreType":"JKS"}` | SSL configuration |
| ssl.clientConnector | object | `{"clientAuth":false,"enabled":false}` | SSL client connector configuration |
| ssl.clientConnector.clientAuth | bool | `false` | Client authentication for the client connector |
| ssl.clientConnector.enabled | bool | `false` | Enable SSL for the client connector (thin clients, JDBC, ODBC) |
| ssl.enabled | bool | `false` | Enable SSL (between nodes) |
| ssl.existingSecret | object | `{"keys":{"ksPass":"","tsPass":""},"name":""}` | Use an existing Secret for SSL keystore/truststore passphrases instead of a chart-managed Secret |
| ssl.existingSecret.keys | object | `{"ksPass":"","tsPass":""}` | Optional mapping to override the expected key names in the existing Secret |
| ssl.existingSecret.keys.ksPass | string | `""` | Key for the keystore password (defaults to 'ignite-ssl-ks-pass') |
| ssl.existingSecret.keys.tsPass | string | `""` | Key for the truststore password (defaults to 'ignite-ssl-ts-pass') |
| ssl.existingSecret.name | string | `""` | Name of the existing Secret containing SSL passphrase keys |
| ssl.keyAlgorithm | string | `"SunX509"` | Key manager algorithm that will be used to create a key manager |
| ssl.keyStoreFilePath | string | `""` | Path to the keystore that stores Ignite node certificates |
| ssl.keyStorePassword | string | `""` | Password used to access the keystore defined above |
| ssl.keyStoreType | string | `"JKS"` | Key store type |
| ssl.manageSecret | bool | `true` | When true (default), the chart may create/manage its own Secret from values when no existingSecret is specified |
| ssl.protocol | string | `"TLSv1.2"` | Protocol |
| ssl.trustStoreFilePath | string | `""` | Path to the truststore used to validate connecting clients |
| ssl.trustStorePassword | string | `""` | Password used to access the truststore defined above |
| ssl.trustStoreType | string | `"JKS"` | Trust store type |
| startupProbe | object | `{"enabled":true,"failureThreshold":15,"httpGet":{"path":"/ignite?cmd=version","port":8080},"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Startup probe configuration |
| startupProbe.enabled | bool | `true` | Enable startup probe |
| terminationGracePeriodSeconds | int | `60` | Pod termination grace period |
| threadPools | object | `{"dataStreamerThreadPoolSize":"","publicThreadPoolSize":"","queryThreadPoolSize":"","serviceThreadPoolSize":"","stripedPoolSize":"","systemThreadPoolSize":""}` | Thread pools |
| threadPools.dataStreamerThreadPoolSize | string | `""` | Data streamer thread pool size |
| threadPools.publicThreadPoolSize | string | `""` | Public thread pool size |
| threadPools.queryThreadPoolSize | string | `""` | Query thread pool size |
| threadPools.serviceThreadPoolSize | string | `""` | Service thread pool size |
| threadPools.stripedPoolSize | string | `""` | Striped thread pool size |
| threadPools.systemThreadPoolSize | string | `""` | System thread pool size |
| timeouts | object | `{"clientFailureDetectionTimeout":60000,"failureDetectionTimeout":30000,"networkTimeout":10000}` | Timeouts |
| timeouts.clientFailureDetectionTimeout | int | `60000` | Client failure detection timeout in milliseconds |
| timeouts.failureDetectionTimeout | int | `30000` | Failure detection timeout in milliseconds |
| timeouts.networkTimeout | int | `10000` | Network timeout in milliseconds |
| tolerations | list | `[]` | Node tolerations |
| topologySpreadConstraints | list | `[{"labelSelector":{"matchLabels":{"app.kubernetes.io/instance":"{{ .Release.Name }}","app.kubernetes.io/name":"{{ include \"ignite.name\" . }}"}},"maxSkew":1,"topologyKey":"kubernetes.io/hostname","whenUnsatisfiable":"ScheduleAnyway"}]` | Topology spread constraints (templated; by default, the pods prefer different Kubernetes nodes, so that a node failure takes as few copies of the same partitions as possible) |
| transactionConfiguration | string | `""` | Transaction configuration |
| updateStrategy | object | `{"rollingUpdate":{"partition":0},"type":"RollingUpdate"}` | StatefulSet update strategy (nodes of different Ignite minor versions cannot form one cluster; before moving to another Ignite minor version, e.g., from 2.18 to 2.19, deactivate the cluster and scale the StatefulSet to 0) |
| userAttributes | string | `""` | User attributes |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
