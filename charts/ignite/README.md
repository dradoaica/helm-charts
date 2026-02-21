# ignite

![Version: 2.17.1](https://img.shields.io/badge/Version-2.17.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.17.0](https://img.shields.io/badge/AppVersion-2.17.0-informational?style=flat-square)

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

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| activationJob.enabled | bool | `true` | Enable the cluster activation job |
| activationJob.image | object | `{"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"curlimages/curl","tag":"8.17.0"}` | Image for the cluster activation job |
| activationJob.resources | object | `{"limits":{"cpu":"100m","memory":"128Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | Resources for the cluster activation job |
| affinity | object | `{}` | Node affinity |
| annotations | object | `{}` | Annotations to add to all resources |
| authentication.enabled | bool | `true` | Enable authentication |
| authentication.igniteUserPassword | string | `""` | Password for the ignite user (defaults to ignite when empty) |
| autoscaling.create | bool | `false` | Create a HorizontalPodAutoscaler |
| autoscaling.maxReplicas | int | `10` | Maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage |
| autoscaling.targetMemoryUtilizationPercentage | int | `80` | Target memory utilization percentage |
| binaryConfiguration | string | `""` | Binary configuration |
| cacheConfiguration | string | `""` | Cache configuration |
| cacheKeyConfiguration | string | `""` | Cache key configuration |
| clientConnector | object | `{"extraConfiguration":""}` | Client connector configuration |
| clientConnector.extraConfiguration | string | `""` | Extra configuration for org.apache.ignite.configuration.ClientConnectorConfiguration bean |
| collisionSpi | string | `""` | Collision SPI |
| communicationSpi | string | `"<bean class=\"org.apache.ignite.spi.communication.tcp.TcpCommunicationSpi\">\n    <property name=\"messageQueueLimit\" value=\"2048\"/>\n    <property name=\"slowClientQueueLimit\" value=\"2048\"/>\n    <property name=\"socketWriteTimeout\" value=\"5000\"/>\n    <property name=\"connectTimeout\" value=\"10000\"/>\n</bean>"` | Communication SPI |
| container.ports | object | `{"jdbc":11211,"jmx":49112,"rest":8080,"spiCommunication":47100,"spiDiscovery":47500,"sql":10800,"thinClients":10900}` | Container ports used by the Pod spec and as Service targetPort values |
| containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}}` | Container security context configuration |
| containerSecurityContext.enabled | bool | `true` | Enable container security context |
| dataStorage | object | `{"extraConfiguration":"","pageEvictionMode":""}` | Data storage configuration |
| dataStorage.extraConfiguration | string | `""` | Extra configuration for org.apache.ignite.configuration.DataStorageConfiguration bean |
| dataStorage.pageEvictionMode | string | `""` | Off-heap eviction policy for in-memory mode (e.g., RANDOM_LRU) |
| deploymentSpi | string | `""` | Deployment SPI |
| encryptionSpi | string | `""` | Encryption SPI |
| env | object | `{"EXTRA_JVM_OPTS":"","EXTRA_OPTION_LIBS":""}` | Environment variables |
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
| image.tag | string | `""` | Main container image tag |
| ingress.annotations | object | `{}` | Additional annotations for the Ingress |
| ingress.className | string | `""` | IngressClass that will be used to implement the Ingress |
| ingress.create | bool | `false` | Create an Ingress for external HTTP access to REST API |
| ingress.hosts | list | `[{"host":"ignite.local","paths":[{"path":"/","pathType":"Prefix","port":8080}]}]` | List of Ingress hosts with paths configuration |
| ingress.tls | list | `[]` | TLS configuration for Ingress |
| labels | object | `{}` | Additional labels to add to all resources |
| lifecycleHooks | object | `{}` | Lifecycle hooks configuration |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/ignite?cmd=version","port":8080},"initialDelaySeconds":5,"periodSeconds":30,"successThreshold":1,"timeoutSeconds":10}` | Liveness probe configuration |
| livenessProbe.enabled | bool | `true` | Enable liveness probe |
| loadBalancingSpi | string | `""` | Load balancing SPI |
| memory.g1HeapRegionSizeMB | string | `""` | JVM G1 Heap region size in MB. If not set, defaults to 1 |
| memory.maxDirectMemorySizeMB | int | `2960` | JVM DirectMemory max size in MB (offHeapMB + checkpointing buffer size + other system regions total size) |
| memory.maxMetaspaceSizeMB | string | `""` | JVM Metaspace max size in MB. If not set, defaults to 256 |
| memory.offHeapMB | int | `2048` | Off-heap memory limit in MB. Configures the maxSize for org.apache.ignite.configuration.DataStorageConfiguration bean (data + indexes) |
| memory.onHeapMB | string | `""` | On-heap memory limit in MB. If set, -Xms and -Xmx will be value. If not set, defaults to 1024 |
| memory.reservedCodeCacheSizeMB | string | `""` | JVM ReservedCodeCache size in MB. If not set, defaults to 240 |
| memoryConfiguration | string | `""` | Memory configuration |
| metrics.enabled | bool | `false` | Enable metrics |
| nameOverride | string | `""` | String to partially override the fullname template with a string (will prepend the release name) |
| networkPolicy.create | bool | `false` | Create a NetworkPolicy |
| networkPolicy.egress | list | `[{"ports":[{"port":53,"protocol":"UDP"},{"port":53,"protocol":"TCP"}],"to":[{"ipBlock":{"cidr":"0.0.0.0/0"}}]}]` | NetworkPolicy egress rules |
| networkPolicy.ingress | list | `[]` | NetworkPolicy ingress rules |
| networkPolicy.name | string | `""` | Name for the NetworkPolicy (defaults to fullname when empty) |
| nodeSelector | object | `{}` | Node selector |
| peerClassLoadingEnabled | bool | `false` | Enable the Ignite's [Zero Deployment](https://ignite.apache.org/docs/ignite2/latest/code-deployment/peer-class-loading.html#enabling-peer-class-loading) |
| persistence.enabled | bool | `true` | Enable persistent settings - both storage and WAL |
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
| podDisruptionBudget.create | bool | `false` | Create a PodDisruptionBudget for high availability |
| podDisruptionBudget.maxUnavailable | string | `""` | Maximum number of pods that can be unavailable during disruptions (mutually exclusive with minAvailable) |
| podDisruptionBudget.minAvailable | int | `1` | Minimum number of pods that must be available during disruptions (mutually exclusive with maxUnavailable) |
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
| revisionHistoryLimit | int | `10` | Number of old ReplicaSets to retain |
| service.ports | object | `{"jdbc":11211,"jmx":49112,"rest":8080,"spiCommunication":47100,"spiDiscovery":47500,"sql":10800,"thinClients":10900}` | Service ports used by the Service spec. targetPort fields reference container.ports.* |
| serviceAccount.annotations | object | `{}` | Additional annotations to add to ServiceAccount |
| serviceAccount.create | bool | `true` | Create a dedicated ServiceAccount |
| serviceAccount.name | string | `""` | Name for the ServiceAccount (autogenerated when empty) |
| serviceConfiguration | string | `""` | Service configuration |
| sqlConfiguration | string | `""` | SQL configuration |
| ssl | object | `{"clientConnector":{"clientAuth":false,"enabled":false},"enabled":false,"keyAlgorithm":"SunX509","keyStoreFilePath":"","keyStorePassword":"","keyStoreType":"JKS","protocol":"TLSv1.2","trustStoreFilePath":"","trustStorePassword":"","trustStoreType":"JKS"}` | SSL configuration |
| ssl.clientConnector | object | `{"clientAuth":false,"enabled":false}` | SSL client connector configuration |
| ssl.clientConnector.clientAuth | bool | `false` | Client authentication for the client connector |
| ssl.clientConnector.enabled | bool | `false` | Enable SSL for the client connector |
| ssl.enabled | bool | `false` | Enable SSL |
| ssl.keyAlgorithm | string | `"SunX509"` | Key manager algorithm that will be used to create a key manager |
| ssl.keyStoreFilePath | string | `""` | Path to the keystore that stores Ignite node certificates |
| ssl.keyStorePassword | string | `""` | Password used to access the keystore defined above |
| ssl.keyStoreType | string | `"JKS"` | Key store type |
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
| topologySpreadConstraints | list | `[]` | Topology spread constraints |
| tracing.enabled | bool | `false` | Enable tracing |
| transactionConfiguration | string | `""` | Transaction configuration |
| updateStrategy | object | `{"rollingUpdate":{"partition":0},"type":"RollingUpdate"}` | StatefulSet update strategy |
| userAttributes | string | `""` | User attributes |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
