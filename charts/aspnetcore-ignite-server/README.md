# aspnetcore-ignite-server

![Version: 2.17.0](https://img.shields.io/badge/Version-2.17.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.17.0](https://img.shields.io/badge/AppVersion-2.17.0-informational?style=flat-square)

Apache Ignite 2 embedded in an ASP.NET Core server with auto-discovery clustering capabilities.

**Homepage:** <https://github.com/dradoaica/AspNetCore.Ignite/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| dradoaica | <dradoaica@gmail.com> | <https://dradoaica.blogspot.com/> |

## Source Code

* <https://github.com/dradoaica/AspNetCore.Ignite/>

## Requirements

Kubernetes: `>= 1.26.0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Node affinity |
| annotations | object | `{}` | Annotations to add to all resources |
| autoscaling.create | bool | `false` | Create a HorizontalPodAutoscaler |
| autoscaling.maxReplicas | int | `10` | Maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage |
| autoscaling.targetMemoryUtilizationPercentage | int | `80` | Target memory utilization percentage |
| container.ports | object | `{"jdbc":11211,"jmx":49112,"rest":8080,"spiCommunication":47100,"spiDiscovery":47500,"sql":10800,"thinClients":10900}` | Container ports used by the Pod spec and as Service targetPort values |
| containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}}` | Container security context configuration |
| containerSecurityContext.enabled | bool | `true` | Enable container security context |
| env | object | `{"DEFAULT_OFF_HEAP_MEMORY":"2048","DEFAULT_ON_HEAP_MEMORY":"1024","ENABLE_AUTHENTICATION":"true","ENABLE_OFF_HEAP_METRICS":"false","METRICS_EXPIRE_TIME_IN_HOURS":"24","METRICS_LOG_FREQUENCY_IN_MINUTES":"5","METRICS_UPDATE_FREQUENCY_IN_SECONDS":"60","SSL_CLIENT_CERTIFICATE_PATH":"","SSL_KEY_STORE_FILE_PATH":"","SSL_TRUST_STORE_FILE_PATH":"","USE_CLIENT_SSL":"false","USE_SSL":"false"}` | Environment variables |
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
| image.repository | string | `"dradoaica/aspnetcore.ignite-server"` | Main container image repository |
| image.tag | string | `""` | Main container image tag |
| ingress.annotations | object | `{}` | Additional annotations for the Ingress |
| ingress.className | string | `""` | IngressClass that will be used to implement the Ingress |
| ingress.create | bool | `false` | Create an Ingress for external HTTP access |
| ingress.hosts | list | `[{"host":"ignite.local","paths":[{"path":"/","pathType":"Prefix","port":8080}]}]` | List of Ingress hosts with paths configuration |
| ingress.tls | list | `[]` | TLS configuration for Ingress |
| labels | object | `{}` | Additional labels to add to all resources |
| lifecycleHooks | object | `{}` | Lifecycle hooks configuration |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/ignite?cmd=version","port":8080},"initialDelaySeconds":5,"periodSeconds":30,"successThreshold":1,"timeoutSeconds":10}` | Liveness probe configuration |
| livenessProbe.enabled | bool | `true` | Enable liveness probe |
| nameOverride | string | `""` | String to partially override the fullname template with a string (will prepend the release name) |
| networkPolicy.create | bool | `false` | Create a NetworkPolicy |
| networkPolicy.egress | list | `[{"ports":[{"port":53,"protocol":"UDP"},{"port":53,"protocol":"TCP"}],"to":[{"ipBlock":{"cidr":"0.0.0.0/0"}}]}]` | NetworkPolicy egress rules |
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
| persistence.size | string | `"16Gi"` | Persistent volume size |
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
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/ignite?cmd=probe","port":8080},"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":10}` | Readiness probe configuration |
| readinessProbe.enabled | bool | `true` | Enable readiness probe |
| replicaCount | int | `1` | Number of pods |
| resources | object | `{"limits":{"cpu":"2","memory":"5Gi"},"requests":{"cpu":"2","memory":"5Gi"}}` | Main container requests/limits with guaranteed QoS (requests = limits)  memory calculation: DEFAULT_ON_HEAP_MEMORY (JVM Heap max size)   + 256MB (JVM Metaspace max size)   + 240MB (JVM ReservedCodeCache size)   + DEFAULT_OFF_HEAP_MEMORY (default region max size; data + indexes (basic use cases will add a 30% increase on top of data))   + MIN(256MB, DEFAULT_OFF_HEAP_MEMORY) (DEFAULT_OFF_HEAP_MEMORY < 1 GB)     || DEFAULT_OFF_HEAP_MEMORY/4 (DEFAULT_OFF_HEAP_MEMORY between 1 GB and 8 GB)     || 2GB (DEFAULT_OFF_HEAP_MEMORY > 8 GB)       (default region checkpointing buffer size)   + 100MB (sysMemPlc region max size)   + 100MB (metastoreMemPlc region max size)   + 100MB (TxLog region max size)   + 100MB (volatileDsMemPlc region max size)   + ~512MB (other overheads; e.g., thread stacks, GC, symbols, etc.) |
| revisionHistoryLimit | int | `10` | Number of old ReplicaSets to retain |
| secrets | object | `{"igniteUserPassword":"ignite","sslClientCertificatePassword":"","sslKeyStorePassword":"","sslTrustStorePassword":""}` | Secrets |
| service.ports | object | `{"jdbc":11211,"jmx":49112,"rest":8080,"spiCommunication":47100,"spiDiscovery":47500,"sql":10800,"thinClients":10900}` | Service ports used by the Service spec. targetPort fields reference container.ports.* |
| serviceAccount.annotations | object | `{}` | Additional annotations to add to ServiceAccount |
| serviceAccount.create | bool | `true` | Create a dedicated ServiceAccount |
| serviceAccount.name | string | `""` | Name for the ServiceAccount (autogenerated when empty) |
| startupProbe | object | `{"enabled":true,"failureThreshold":15,"httpGet":{"path":"/ignite?cmd=version","port":8080},"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Startup probe configuration |
| startupProbe.enabled | bool | `true` | Enable startup probe |
| terminationGracePeriodSeconds | int | `60` | Pod termination grace period |
| tolerations | list | `[]` | Node tolerations |
| topologySpreadConstraints | list | `[]` | Topology spread constraints |
| updateStrategy | object | `{"rollingUpdate":{"partition":0},"type":"RollingUpdate"}` | StatefulSet update strategy |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
