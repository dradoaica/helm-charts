# clamav-openshift

![Version: 1.5.1](https://img.shields.io/badge/Version-1.5.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.5.1](https://img.shields.io/badge/AppVersion-1.5.1-informational?style=flat-square)

ClamAV is an open-source antivirus engine for detecting trojans, viruses, malware & other malicious threats. This chart deploys ClamAV as a StatefulSet with persistence support.

**Homepage:** <https://github.com/dradoaica/clamav-docker-openshift/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| dradoaica | <dradoaica@gmail.com> | <https://dradoaica.blogspot.com/> |

## Source Code

* <https://github.com/dradoaica/clamav-docker-openshift/>

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
| clamd.maxConnectionQueueLength | int | `100` | Maximum length the queue of pending connections may grow to |
| clamd.maxFileSize | int | `25` | Maximum file size to scan (in MB) |
| clamd.maxQueue | int | `100` | Maximum number of queued items (including those being processed by MaxThreads threads) |
| clamd.maxScanSize | int | `100` | Maximum scan size permitted (in MB) |
| clamd.maxThreads | int | `4` | Maximum number of threads running at the same time |
| clamd.sendBufTimeout | int | `500` | Time to wait (in milliseconds) if send buffer is full (keep low to avoid clamd hanging) |
| clamd.streamMaxLength | int | `100` | Close the connection when the data size limit is exceeded. The value should match your MTA's limit for a maximum attachment size |
| container.ports | object | `{"clamd":3310,"milter":7357}` | Container ports used by the Pod spec and as Service targetPort values |
| containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}}` | Container security context configuration |
| containerSecurityContext.enabled | bool | `true` | Enable container security context |
| env | object | `{}` | Environment variables |
| extraContainers | list | `[]` | Extra sidecar containers to inject into the main Pod spec |
| extraEnvFrom | list | `[]` | Extra envFrom entries to inject into the main container |
| extraEnvVars | list | `[]` | Extra environment variables to inject into the main container |
| extraEnvVarsCM | string | `""` | Name of a ConfigMap with extra environment variables to inject into the main container |
| extraEnvVarsSecret | string | `""` | Name of a Secret with extra environment variables to inject into the main container |
| extraInitContainers | list | `[]` | Extra init containers to inject into the main Pod spec |
| extraVolumeMounts | list | `[]` | Extra volume mounts to add to the main container |
| extraVolumes | list | `[]` | Extra volumes to add to the main Pod spec |
| freshclam.checks | int | `24` | Number of database checks per day |
| freshclam.httpProxyHost | string | `""` | HTTP proxy host for freshclam updates |
| freshclam.httpProxyPassword | string | `""` | HTTP proxy password for freshclam updates |
| freshclam.httpProxyPort | string | `""` | HTTP proxy port for freshclam updates |
| freshclam.httpProxyUsername | string | `""` | HTTP proxy username for freshclam updates |
| freshclam.mirrors | string | `"database.clamav.net"` | ClamAV database mirror servers |
| fullnameOverride | string | `""` | String to fully override the fullname template with a string |
| global.imagePullSecrets | list | `[]` | Global pod image pull secrets |
| global.imageRegistry | string | `""` | Global container image registry override |
| image.pullPolicy | string | `"IfNotPresent"` | Main container image pull policy |
| image.registry | string | `"docker.io"` | Main container image registry |
| image.repository | string | `"dradoaica/clamav-openshift"` | Main container image repository |
| image.tag | string | `""` | Main container image tag |
| labels | object | `{}` | Additional labels to add to all resources |
| lifecycleHooks | object | `{}` | Lifecycle hooks configuration |
| livenessProbe | object | `{"enabled":true,"exec":{"command":["/usr/local/bin/clamdcheck.sh"]},"failureThreshold":3,"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":5}` | Liveness probe configuration |
| livenessProbe.enabled | bool | `true` | Enable liveness probe |
| milter.enabled | bool | `false` | Enable Milter |
| milter.maxFileSize | int | `25` | Maximum file size to scan (in MB) |
| nameOverride | string | `""` | String to partially override the fullname template with a string (will prepend the release name) |
| networkPolicy.create | bool | `false` | Create a NetworkPolicy |
| networkPolicy.egress | list | `[{"ports":[{"port":53,"protocol":"UDP"},{"port":53,"protocol":"TCP"}],"to":[{"ipBlock":{"cidr":"0.0.0.0/0"}}]},{"ports":[{"port":80,"protocol":"TCP"},{"port":443,"protocol":"TCP"}],"to":[{"ipBlock":{"cidr":"0.0.0.0/0"}}]}]` | NetworkPolicy egress rules |
| networkPolicy.ingress | list | `[]` | NetworkPolicy ingress rules |
| networkPolicy.name | string | `""` | Name for the NetworkPolicy (defaults to fullname when empty) |
| nodeSelector | object | `{}` | Node selector |
| persistence | object | `{"accessModes":["ReadWriteOnce"],"annotations":{},"labels":{},"persistentVolumeClaimRetentionPolicy":{"enabled":false,"whenDeleted":"Retain","whenScaled":"Retain"},"size":"2Gi","storageClass":""}` | Persistence is always enabled |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Persistent volume access modes |
| persistence.annotations | object | `{}` | Annotations to add to the PersistentVolumeClaim |
| persistence.labels | object | `{}` | Labels to add to the PersistentVolumeClaim |
| persistence.persistentVolumeClaimRetentionPolicy.enabled | bool | `false` | Enable persistent volume retention policy |
| persistence.persistentVolumeClaimRetentionPolicy.whenDeleted | string | `"Retain"` | Volume retention behavior that applies when the StatefulSet is deleted |
| persistence.persistentVolumeClaimRetentionPolicy.whenScaled | string | `"Retain"` | Volume retention behavior when the replica count of the StatefulSet is reduced |
| persistence.size | string | `"2Gi"` | Persistent volume size for virus signature databases |
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
| readinessProbe | object | `{"enabled":true,"exec":{"command":["/usr/local/bin/clamdcheck.sh"]},"failureThreshold":3,"initialDelaySeconds":5,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":5}` | Readiness probe configuration |
| readinessProbe.enabled | bool | `true` | Enable readiness probe |
| replicaCount | int | `1` | Number of pods |
| resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"300m","memory":"2Gi"}}` | Main container requests/limits |
| revisionHistoryLimit | int | `10` | Number of old ReplicaSets to retain |
| service.nodePorts.clamd | string | `""` | NodePort value for ClamD when service.type is NodePort |
| service.nodePorts.milter | string | `""` | NodePort value for Milter when service.type is NodePort |
| service.ports | object | `{"clamd":3310,"milter":7357}` | Service ports used by the Service spec. targetPort fields reference container.ports.* |
| service.ports.clamd | int | `3310` | Service port for ClamD |
| service.ports.milter | int | `7357` | Service port for Milter |
| service.type | string | `"ClusterIP"` | Service type (ClusterIP, NodePort, LoadBalancer) |
| serviceAccount.annotations | object | `{}` | Additional annotations to add to ServiceAccount |
| serviceAccount.create | bool | `true` | Create a dedicated ServiceAccount |
| serviceAccount.name | string | `""` | Name for the ServiceAccount (autogenerated when empty) |
| startupProbe | object | `{"enabled":true,"exec":{"command":["/usr/local/bin/clamdcheck.sh"]},"failureThreshold":30,"initialDelaySeconds":5,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":5}` | Startup probe configuration |
| startupProbe.enabled | bool | `true` | Enable startup probe |
| terminationGracePeriodSeconds | int | `60` | Pod termination grace period |
| tolerations | list | `[]` | Node tolerations |
| topologySpreadConstraints | list | `[]` | Topology spread constraints |
| updateStrategy | object | `{"rollingUpdate":{"partition":0},"type":"RollingUpdate"}` | StatefulSet update strategy |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
