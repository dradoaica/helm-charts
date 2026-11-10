# clamav-openshift

![Version: 1.5.5](https://img.shields.io/badge/Version-1.5.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.5.5](https://img.shields.io/badge/AppVersion-1.5.5-informational?style=flat-square)

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

## Configuration

clamd listens on TCP (`service.ports.clamd`) without authentication: restrict access with `networkPolicy.create` and
`networkPolicy.ingress`. The first start of a pod downloads the whole signature database (into its persistent volume)
before starting clamd, and each replica downloads it on its own: with many replicas, use a private mirror
(`freshclam.mirrors`), as `database.clamav.net` rate-limits clients that download too often.

clamd, freshclam and the milter log to the console (`kubectl logs`). The HTTP proxy password of freshclam is kept in a
Secret (`freshclam.httpProxyPassword` or `freshclam.existingSecret`) and added to `freshclam.conf` by an init container.

## Upgrading to 1.5.5

Upgrade with `--reset-then-reuse-values` (not `--reuse-values`, which keeps the 1.5.4 defaults and misses the new
settings; the chart then fails with a message):

```shell
helm upgrade <release> <chart> --version 1.5.5 --reset-then-reuse-values
```

- `freshclam.checks` now applies: the image starts freshclam with `--checks` (1 by default), which overrode the
  `Checks` of `freshclam.conf`, so the databases were checked once a day whatever the value (24 by default).
- `freshclam.httpProxyPassword` moved from the ConfigMap to a Secret (or use `freshclam.existingSecret`).
- The log files under `/var/log/clamav` are gone: the logs were already on the console, and the rotated files piled up
  in the pod. `logging.verbose` and `clamd.logClean` keep the previous behavior by default.
- The test pod is no longer selected by the Service and the PodDisruptionBudget; with `networkPolicy.create`, the
  NetworkPolicy allows it (`networkPolicy.allowTests`).
- `podDisruptionBudget.maxUnavailable`, when set, is used instead of `minAvailable` (setting both was refused).
- New settings: `clamd.concurrentDatabaseReload` (disable it to keep a single copy of the database in memory).
- The pods prefer different nodes (`topologySpreadConstraints`), no longer mount the ServiceAccount token, and get up to
  10 minutes to start (`startupProbe.failureThreshold`).

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
| clamd.concurrentDatabaseReload | bool | `true` | Reload the signature database in the background, so that clamd keeps scanning (needs memory for two copies of the database, about 1 GB more; when disabled, clamd stops scanning while reloading) |
| clamd.logClean | bool | `true` | Log the clean files too (one line per scan) |
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
| freshclam.checks | int | `24` | Number of database checks per day (1 to 50) |
| freshclam.existingSecret | object | `{"key":"","name":""}` | Use an existing Secret for the HTTP proxy password instead of a chart-managed Secret |
| freshclam.existingSecret.key | string | `""` | Key in the existing Secret that holds the password (defaults to 'http-proxy-password') |
| freshclam.existingSecret.name | string | `""` | Name of the existing Secret containing the HTTP proxy password |
| freshclam.httpProxyHost | string | `""` | HTTP proxy host for freshclam updates |
| freshclam.httpProxyPassword | string | `""` | HTTP proxy password for freshclam updates (stored in a chart-managed Secret) |
| freshclam.httpProxyPort | string | `""` | HTTP proxy port for freshclam updates |
| freshclam.httpProxyUsername | string | `""` | HTTP proxy username for freshclam updates |
| freshclam.mirrors | string | `"database.clamav.net"` | ClamAV database mirror servers |
| fullnameOverride | string | `""` | String to fully override the fullname template with a string |
| global.imagePullSecrets | list | `[]` | Global pod image pull secrets |
| global.imageRegistry | string | `""` | Global container image registry override |
| image.pullPolicy | string | `"IfNotPresent"` | Main container image pull policy |
| image.registry | string | `"ghcr.io"` | Main container image registry |
| image.repository | string | `"dradoaica/clamav-docker-openshift"` | Main container image repository |
| image.tag | string | `""` | Main container image tag |
| labels | object | `{}` | Additional labels to add to all resources |
| lifecycleHooks | object | `{}` | Lifecycle hooks configuration |
| livenessProbe | object | `{"enabled":true,"exec":{"command":["/usr/local/bin/clamdcheck.sh"]},"failureThreshold":3,"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":5}` | Liveness probe configuration |
| livenessProbe.enabled | bool | `true` | Enable liveness probe |
| logging.verbose | bool | `true` | Verbose logging for clamd, freshclam and the milter (the logs go to the console, i.e., kubectl logs) |
| milter.enabled | bool | `false` | Enable Milter |
| milter.maxFileSize | int | `25` | Maximum file size to scan (in MB) |
| nameOverride | string | `""` | String to partially override the fullname template with a string (will prepend the release name) |
| networkPolicy.allowTests | bool | `true` | Allow ingress from the chart's test pods (helm test) |
| networkPolicy.create | bool | `false` | Create a NetworkPolicy |
| networkPolicy.egress | list | `[{"ports":[{"port":53,"protocol":"UDP"},{"port":53,"protocol":"TCP"}],"to":[{"ipBlock":{"cidr":"0.0.0.0/0"}}]},{"ports":[{"port":80,"protocol":"TCP"},{"port":443,"protocol":"TCP"}],"to":[{"ipBlock":{"cidr":"0.0.0.0/0"}}]}]` | NetworkPolicy egress rules |
| networkPolicy.ingress | list | `[]` | NetworkPolicy ingress rules (add rules for the clients that need access to clamd or the milter) |
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
| podDisruptionBudget.maxUnavailable | string | `""` | Maximum number of pods that can be unavailable during disruptions (if set, used instead of minAvailable; e.g., "50%") |
| podDisruptionBudget.minAvailable | int | `1` | Minimum number of pods that must be available during disruptions (used when maxUnavailable is empty) |
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
| startupProbe | object | `{"enabled":true,"exec":{"command":["/usr/local/bin/clamdcheck.sh"]},"failureThreshold":60,"initialDelaySeconds":5,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":5}` | Startup probe configuration (up to 605 s; the first start of a pod downloads the whole signature database before starting clamd) |
| startupProbe.enabled | bool | `true` | Enable startup probe |
| terminationGracePeriodSeconds | int | `60` | Pod termination grace period |
| tolerations | list | `[]` | Node tolerations |
| topologySpreadConstraints | list | `[{"labelSelector":{"matchLabels":{"app.kubernetes.io/instance":"{{ .Release.Name }}","app.kubernetes.io/name":"{{ include \"clamav-openshift.name\" . }}"}},"maxSkew":1,"topologyKey":"kubernetes.io/hostname","whenUnsatisfiable":"ScheduleAnyway"}]` | Topology spread constraints (templated; by default, the pods prefer different Kubernetes nodes) |
| updateStrategy | object | `{"rollingUpdate":{"partition":0},"type":"RollingUpdate"}` | StatefulSet update strategy |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
