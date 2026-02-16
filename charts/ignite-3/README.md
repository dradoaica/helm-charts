# ignite-3

![Version: 3.1.0](https://img.shields.io/badge/Version-3.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.1.0](https://img.shields.io/badge/AppVersion-3.1.0-informational?style=flat-square)

Apache Ignite is a distributed database for high-performance computing with in-memory speed.

**Homepage:** <https://ignite.apache.org/docs/ignite3/latest/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| dradoaica | <dradoaica@gmail.com> | <https://dradoaica.blogspot.com/> |

## Source Code

* <https://github.com/apache/ignite-3>

## Requirements

Kubernetes: `>= 1.26.0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Node affinity |
| annotations | object | `{}` | Annotations to add to all resources |
| authentication.enabled | bool | `true` | Enable authentication |
| authentication.igniteUserPassword | string | `""` | Password for the ignite user (defaults to ignite when empty) |
| autoscaling.create | bool | `false` | Create a HorizontalPodAutoscaler |
| autoscaling.maxReplicas | int | `10` | Maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage |
| autoscaling.targetMemoryUtilizationPercentage | int | `80` | Target memory utilization percentage |
| container.ports | object | `{"cluster":3344,"management":10300,"managementSsl":10400,"rest":10800}` | Container ports used by the Pod spec and as Service targetPort values |
| containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}}` | Container security context configuration |
| containerSecurityContext.enabled | bool | `true` | Enable container security context |
| dataStorage.engine | string | `"aipersist"` | Storage engine to use (aipersist for persistence mode, aimem for in-memory mode) |
| env | object | `{"EXTRA_JVM_OPTS":""}` | Environment variables |
| extraContainers | list | `[]` | Extra sidecar containers to inject into the main Pod spec |
| extraEnvFrom | list | `[]` | Extra envFrom entries to inject into the main container |
| extraEnvVars | list | `[]` | Extra environment variables to inject into the main container |
| extraEnvVarsCM | string | `""` | Name of a ConfigMap with extra environment variables to inject into the main container |
| extraEnvVarsSecret | string | `""` | Name of a Secret with extra environment variables to inject into the main container |
| extraInitContainers | list | `[]` | Extra init containers to inject into the main Pod spec |
| extraVolumeMounts | list | `[]` | Extra volume mounts to add to the main container |
| extraVolumes | list | `[]` | Extra volumes to add to the main Pod spec |
| fullnameOverride | string | `""` | String to fully override the fullname template with a string |
| global.imagePullSecrets | list | `[]` | Global pod image pull secrets |
| global.imageRegistry | string | `""` | Global container image registry override |
| image.pullPolicy | string | `"IfNotPresent"` | Main container image pull policy |
| image.registry | string | `"docker.io"` | Main container image registry |
| image.repository | string | `"apacheignite/ignite"` | Main container image repository |
| image.tag | string | `""` | Main container image tag |
| ingress.annotations | object | `{}` | Additional annotations for the Ingress |
| ingress.className | string | `""` | IngressClass that will be used to implement the Ingress |
| ingress.create | bool | `false` | Create an Ingress for external HTTP access |
| ingress.hosts | list | `[{"host":"ignite.local","paths":[{"path":"/","pathType":"Prefix","port":10800}]}]` | List of Ingress hosts with paths for REST and Management APIs |
| ingress.tls | list | `[]` | TLS configuration for Ingress |
| initializationJob.enabled | bool | `true` | Enable the cluster initialization job with topology verification and intelligent CMG sizing |
| initializationJob.resources | object | `{"limits":{"cpu":"1","memory":"2Gi"},"requests":{"cpu":"500m","memory":"2Gi"}}` | Resources for the cluster initialization job |
| jmx.agent.image | object | `{"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"busybox","tag":1.36}` | JMX agent image (registry/repository:tag and pull policy) |
| jmx.agent.resources | object | `{"limits":{"cpu":"100m","memory":"128Mi"},"requests":{"cpu":"50m","memory":"64Mi"}}` | JMX agent container resources |
| jmx.config | string | `"lowercaseOutputName: true\nlowercaseOutputLabelNames: true\n"` | JMX exporter configuration |
| jmx.enabled | bool | `false` | Enable JMX agent sidecar for Prometheus scraping |
| jmx.port | int | `9404` | JMX agent port |
| labels | object | `{}` | Additional labels to add to all resources |
| lifecycleHooks | object | `{}` | Lifecycle hooks configuration |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/management/v1/node/state","port":10300},"initialDelaySeconds":5,"periodSeconds":30,"successThreshold":1,"timeoutSeconds":10}` | Liveness probe configuration |
| livenessProbe.enabled | bool | `true` | Enable liveness probe |
| memory.g1HeapRegionSizeMb | string | `""` | JVM G1 Heap region size in MB. If not set, defaults to 1 |
| memory.maxDirectMemorySizeMb | int | `2560` | JVM DirectMemory max size in MB (offHeapMb + checkpointing buffer size) |
| memory.maxMetaspaceSizeMb | string | `""` | JVM Metaspace max size in MB. If not set, defaults to 256 |
| memory.offHeapMb | int | `2048` | Off-heap memory limit in MB. Configures the sizeBytes for the default storage profile (data + indexes) |
| memory.onHeapMb | string | `""` | On-heap memory limit in MB. If set, JVM_MIN_MEM and JVM_MAX_MEM will be value. If not set, defaults to 1024 |
| memory.reservedCodeCacheSizeMb | string | `""` | JVM ReservedCodeCache size in MB. If not set, defaults to 240 |
| nameOverride | string | `""` | String to partially override the fullname template with a string (will prepend the release name) |
| networkPolicy.create | bool | `false` | Create a NetworkPolicy |
| networkPolicy.egress | list | `[{"ports":[{"port":53,"protocol":"UDP"},{"port":53,"protocol":"TCP"}],"to":[{"ipBlock":{"cidr":"0.0.0.0/0"}}]},{"ports":[{"port":443,"protocol":"TCP"}],"to":[{"ipBlock":{"cidr":"0.0.0.0/0"}}]}]` | NetworkPolicy egress rules |
| networkPolicy.ingress | list | `[]` | NetworkPolicy ingress rules |
| networkPolicy.name | string | `""` | Name for the NetworkPolicy (defaults to fullname when empty) |
| nodeSelector | object | `{}` | Node selector |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Persistent volume access modes |
| persistence.annotations | object | `{}` | Annotations to add to the PersistentVolumeClaim |
| persistence.enabled | bool | `true` | Enable persistent settings |
| persistence.labels | object | `{}` | Labels to add to the PersistentVolumeClaim |
| persistence.persistentVolumeClaimRetentionPolicy.enabled | bool | `false` | Enable persistent volume retention policy |
| persistence.persistentVolumeClaimRetentionPolicy.whenDeleted | string | `"Retain"` | Volume retention behavior that applies when the StatefulSet is deleted |
| persistence.persistentVolumeClaimRetentionPolicy.whenScaled | string | `"Retain"` | Volume retention behavior when the replica count of the StatefulSet is reduced |
| persistence.size | string | `"10Gi"` | Persistent volume size |
| persistence.storageClass | string | `""` | Persistent volume storage class (empty string uses cluster default) |
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
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/management/v1/node/state","port":10300},"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":10}` | Readiness probe configuration |
| readinessProbe.enabled | bool | `true` | Enable readiness probe |
| replicaCount | int | `1` | Number of pods |
| resources | object | `{"limits":{"cpu":"2","memory":"5Gi"},"requests":{"cpu":"2","memory":"5Gi"}}` | Main container requests/limits with guaranteed QoS (requests = limits)  memory calculation: onHeapMb (JVM Heap max size)   + maxMetaspaceSizeMb (JVM Metaspace max size)   + reservedCodeCacheSizeMb (JVM ReservedCodeCache size)   + offHeapMb (default storage profile max size; data + indexes (basic use cases will add a 30% increase on top of data))   + MIN(256MB, offHeapMb) (offHeapMb < 1 GB)     || offHeapMb/4 (offHeapMb between 1 GB and 8 GB)     || 2GB (offHeapMb > 8 GB)       (default storage profile checkpointing buffer size)   + ~512MB (other overheads; e.g., thread stacks, GC, symbols, etc.) |
| revisionHistoryLimit | int | `10` | Number of old ReplicaSets to retain |
| service.ports | object | `{"cluster":3344,"jmx":9404,"management":10300,"managementSsl":10400,"rest":10800}` | Service ports used by the Service spec. targetPort fields reference container.ports.* |
| serviceAccount.annotations | object | `{}` | Additional annotations to add to ServiceAccount |
| serviceAccount.create | bool | `true` | Create a dedicated ServiceAccount |
| serviceAccount.name | string | `""` | Name for the ServiceAccount (autogenerated when empty) |
| ssl.clientConnector.ciphers | string | `""` | Optional cipher suite list for the client connector |
| ssl.clientConnector.clientAuth | string | `"none"` | Client authentication mode for the client connector (e.g., none, require) |
| ssl.clientConnector.enabled | bool | `false` | Enable SSL for the client connector |
| ssl.clientConnector.keyStoreFilePath | string | `""` | Path to the keystore used by the client connector |
| ssl.clientConnector.keyStorePassword | string | `""` | Password for the client connector keystore |
| ssl.clientConnector.keyStoreType | string | `"PKCS12"` | Keystore type for the client connector |
| ssl.clientConnector.trustStoreFilePath | string | `""` | Path to the truststore used by the client connector |
| ssl.clientConnector.trustStorePassword | string | `""` | Password for the client connector truststore |
| ssl.clientConnector.trustStoreType | string | `"PKCS12"` | Truststore type for the client connector |
| ssl.network.ciphers | string | `""` | Optional cipher suite list for the network interface |
| ssl.network.clientAuth | string | `"none"` | Client authentication mode for the network interface (e.g., none, require) |
| ssl.network.enabled | bool | `false` | Enable SSL for the internal network interface |
| ssl.network.keyStoreFilePath | string | `""` | Path to the keystore used by the network interface |
| ssl.network.keyStorePassword | string | `""` | Password for the network interface keystore |
| ssl.network.keyStoreType | string | `"PKCS12"` | Keystore type for the network interface |
| ssl.network.trustStoreFilePath | string | `""` | Path to the truststore used by the network interface |
| ssl.network.trustStorePassword | string | `""` | Password for the network interface truststore |
| ssl.network.trustStoreType | string | `"PKCS12"` | Truststore type for the network interface |
| ssl.rest.ciphers | string | `""` | Optional cipher suite list for the REST endpoint |
| ssl.rest.clientAuth | string | `"none"` | Client authentication mode for the REST endpoint (e.g., none, require) |
| ssl.rest.enabled | bool | `false` | Enable SSL for the REST endpoint |
| ssl.rest.keyStoreFilePath | string | `""` | Path to the keystore used by the REST endpoint |
| ssl.rest.keyStorePassword | string | `""` | Password for the REST endpoint keystore |
| ssl.rest.keyStoreType | string | `"PKCS12"` | Keystore type for the REST endpoint |
| ssl.rest.trustStoreFilePath | string | `""` | Path to the truststore used by the REST endpoint |
| ssl.rest.trustStorePassword | string | `""` | Password for the REST endpoint truststore |
| ssl.rest.trustStoreType | string | `"PKCS12"` | Truststore type for the REST endpoint |
| startupProbe | object | `{"enabled":true,"failureThreshold":15,"httpGet":{"path":"/management/v1/node/state","port":10300},"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Startup probe configuration |
| startupProbe.enabled | bool | `true` | Enable startup probe |
| terminationGracePeriodSeconds | int | `60` | Pod termination grace period |
| tolerations | list | `[]` | Node tolerations |
| topologySpreadConstraints | list | `[]` | Topology spread constraints |
| updateStrategy | object | `{"rollingUpdate":{"partition":0},"type":"RollingUpdate"}` | StatefulSet update strategy |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
