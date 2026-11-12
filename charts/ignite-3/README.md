# ignite-3

![Version: 3.1.2](https://img.shields.io/badge/Version-3.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.1.0](https://img.shields.io/badge/AppVersion-3.1.0-informational?style=flat-square)

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

## Configuration

The chart renders the node configuration (HOCON) into a ConfigMap; `extraConfiguration` is merged into it, e.g.:

```yaml
extraConfiguration: |
  ignite.sql.execution.threadCount=8
  ignite.raft.fsync=true
```

The initialization job (a post-install and post-upgrade hook) initializes the cluster with the `ignite` user and
`authentication.igniteUserPassword`, and on later upgrades changes that password when it differs (with
`cluster config update`, without restarting the nodes). It authenticates with the new, the previous
(`authentication.igniteUserPreviousPassword`) or the default password, so set the previous one when the current password
is neither of the others.

The SSL key store and trust store passwords are rendered into the ConfigMap, as Ignite 3 does not substitute environment
variables in its node configuration (see SECURITY.md).

The probes check the REST port by default. `examples/node-state-probes-values.yaml` has probes on the node state
endpoint (`/management/v1/node/state`) instead: with authentication, the chart adds the `Authorization` header of the
`ignite` user to `httpGet` probes, with the limits listed in that file.

## Status of Apache Ignite 3

As of October 2026, there are no plans for the next Apache Ignite 3 release: 3.1.0 remains available, and the community
recommends Apache Ignite 2.x (see the [ignite](../ignite/README.md) chart) for new projects and production deployments.

This chart therefore deploys Ignite 3.1.0. Its 3.2.x versions, a preview for the unreleased Ignite 3.2.0, are withdrawn;
chart 3.1.2 and later carry all their changes.

## Upgrading from 3.1.1 or a withdrawn 3.2.x

Upgrade with `--reset-then-reuse-values` (`--reuse-values` keeps the old defaults, e.g., `rbac.create` and the writable
root filesystem, and misses the new settings, e.g., `jmx.agent.sha256`; the chart fails with a message on such values):

```shell
helm upgrade <release> <chart> --version 3.1.2 --reset-then-reuse-values
```

A release of a 3.2.x chart moves to 3.1.2 the same way (Helm does not mind the lower version number).

- The probes check the REST port (`tcpSocket`) by default: Ignite 3.1 has no `/health` endpoints. The probe
  overrides of the former `examples/ignite-3.1-values.yaml` are no longer needed in your values.
- The image defaults to 3.1.0 (`appVersion`).
- The autoscaler (`autoscaling.create`) only scales up, on CPU only (`autoscaling.targetMemoryUtilizationPercentage` is
  refused), with `autoscaling.minReplicas` not below `replicaCount`.
- The CLI works with `kubectl exec` on the read-only root filesystem (it needs `XDG_CONFIG_HOME` and `XDG_STATE_HOME`,
  now set).
- `ssl.existingSecret` is refused with SSL enabled: the nodes read the SSL passwords from the ConfigMap only, so an
  existing Secret left them empty. The passwords are now escaped in the configuration (a `"` or `\\` broke it).
- Changing `authentication.igniteUserPassword` (or the existing Secret) now changes the password of the `ignite` user;
  it used to make the initialization job fail.
- `rbac.create` defaults to false and the pods no longer mount the ServiceAccount token: Ignite 3 does not use the
  Kubernetes API (the nodes find each other through the headless Service).
- The default storage profile only has the keys of its engine (`dataStorage.engine`: aipersist, aimem or rocksdb), so
  aimem and rocksdb now work.
- `jmx.agent.url` and `jmx.agent.sha256`: the pods verify the downloaded JMX agent, and add the prometheus.io annotations
  with `jmx.enabled`.
- The containers run with a read-only root filesystem (writable `emptyDir` volumes for `/tmp`, the CLI's home
  `/home/ignite` and, without persistence, the work directory), and the initialization job and the JMX agent init
  container with the chart's security contexts (restricted Pod Security Standard). Write other files to a volume of
  `extraVolumes`, or set `containerSecurityContext.readOnlyRootFilesystem` to false.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Node affinity |
| annotations | object | `{}` | Annotations to add to all resources |
| authentication.enabled | bool | `true` | Enable authentication |
| authentication.existingSecret | object | `{"key":"","name":"","previousKey":""}` | Use an existing Secret for the ignite user password instead of a chart-managed Secret |
| authentication.existingSecret.key | string | `""` | Key in the existing Secret that holds the password (defaults to 'ignite-user-password') |
| authentication.existingSecret.name | string | `""` | Name of the existing Secret containing the ignite user password |
| authentication.existingSecret.previousKey | string | `""` | Key in the existing Secret that holds the previous password (defaults to 'ignite-user-previous-password'; optional) |
| authentication.igniteUserPassword | string | `""` | Password for the ignite user (defaults to ignite when empty), set by the initialization job at initialization and changed by it on upgrade |
| authentication.igniteUserPreviousPassword | string | `""` | Current password of the ignite user, when rotating it to igniteUserPassword |
| authentication.manageSecret | bool | `true` | When true (default), the chart may create/manage its own Secret from values when no existingSecret is specified |
| autoscaling.create | bool | `false` | Create a HorizontalPodAutoscaler that only scales up - see the values.yaml comments |
| autoscaling.maxReplicas | int | `10` | Maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas (not below replicaCount) |
| autoscaling.scaleUp | object | `{"policies":[{"periodSeconds":600,"type":"Pods","value":1}],"stabilizationWindowSeconds":600}` | Scale-up behavior (by default, one pod every 10 minutes, as every added node triggers rebalancing) |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage |
| container.ports | object | `{"cluster":3344,"management":10300,"managementSsl":10400,"rest":10800}` | Container ports used by the Pod spec and as Service targetPort values |
| container.ports.management | int | `10300` | REST/Management API (HTTP) |
| container.ports.managementSsl | int | `10400` | REST/Management API (HTTPS) |
| container.ports.rest | int | `10800` | Client connector (binary protocol for thin clients and JDBC; not HTTP) |
| containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}}` | Container security context configuration |
| containerSecurityContext.enabled | bool | `true` | Enable container security context |
| dataStorage.engine | string | `"aipersist"` | Storage engine of the default storage profile, sized by memory.offHeapMB (aipersist for persistence, aimem for in-memory, rocksdb) |
| env | object | `{"EXTRA_JVM_OPTS":""}` | Environment variables |
| extraConfiguration | string | `""` | Extra node configuration (HOCON), merged into the chart's (e.g., `ignite.sql.execution.threadCount=8`; a list, e.g., `ignite.storage.profiles`, replaces the chart's) |
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
| image.tag | string | `""` | Main container image tag (defaults to appVersion when empty) |
| ingress.annotations | object | `{}` | Additional annotations for the Ingress |
| ingress.className | string | `""` | IngressClass that will be used to implement the Ingress |
| ingress.create | bool | `false` | Create an Ingress for external HTTP access |
| ingress.hosts | list | `[{"host":"ignite.local","paths":[{"path":"/","pathType":"Prefix","port":10300}]}]` | List of Ingress hosts with paths for REST and Management APIs |
| ingress.tls | list | `[]` | TLS configuration for Ingress |
| initializationJob.activeDeadlineSeconds | int | `1800` | Maximum duration of the job in seconds (it waits for every pod) |
| initializationJob.enabled | bool | `true` | Enable the cluster initialization job with topology verification and intelligent CMG sizing |
| initializationJob.resources | object | `{"limits":{"cpu":"1","memory":"2Gi"},"requests":{"cpu":"500m","memory":"2Gi"}}` | Resources for the cluster initialization job |
| jmx.agent.image | object | `{"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"busybox","tag":1.36}` | Image of the init container downloading the agent (needs wget and sha256sum) |
| jmx.agent.resources | object | `{"limits":{"cpu":"100m","memory":"128Mi"},"requests":{"cpu":"50m","memory":"64Mi"}}` | JMX agent container resources |
| jmx.agent.sha256 | string | `"ba74aad73934e59f4ca9c0779b49f1663c1fc7a81d5d99fc665bd5e5039310f5"` | SHA-256 checksum of the jar at url (the pod does not start with another jar) |
| jmx.agent.url | string | `"https://github.com/prometheus/jmx_exporter/releases/download/1.3.0/jmx_prometheus_javaagent-1.3.0.jar"` | URL of the Prometheus JMX exporter Java agent, downloaded when a pod starts (e.g., from an internal mirror) |
| jmx.config | string | `"lowercaseOutputName: true\nlowercaseOutputLabelNames: true\n"` | JMX exporter configuration |
| jmx.enabled | bool | `false` | Enable JMX agent sidecar for Prometheus scraping |
| jmx.port | int | `9404` | JMX agent port |
| labels | object | `{}` | Additional labels to add to all resources |
| lifecycleHooks | object | `{}` | Lifecycle hooks configuration |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"initialDelaySeconds":5,"periodSeconds":30,"successThreshold":1,"tcpSocket":{"port":10300},"timeoutSeconds":10}` | Liveness probe configuration |
| livenessProbe.enabled | bool | `true` | Enable liveness probe |
| memory.g1HeapRegionSizeMB | string | `""` | JVM G1 Heap region size in MB (a power of 2 from 1 to 32). If not set, what the JVM would choose (about 2048 regions; 1 MB for the default heap) |
| memory.maxDirectMemorySizeMB | int | `2560` | JVM DirectMemory max size in MB (offHeapMB + checkpointing buffer size) |
| memory.maxMetaspaceSizeMB | string | `""` | JVM Metaspace max size in MB. If not set, defaults to 256 |
| memory.offHeapMB | int | `2048` | Off-heap memory limit in MB. Configures the sizeBytes for the default storage profile (data + indexes) |
| memory.onHeapMB | string | `""` | On-heap memory limit in MB (the JVM heap; JVM_MIN_MEM and JVM_MAX_MEM). If not set, defaults to 1024 |
| memory.reservedCodeCacheSizeMB | string | `""` | JVM ReservedCodeCache size in MB. If not set, defaults to 240 |
| minReadySeconds | int | `60` | Seconds a started pod must stay ready before the next one starts or restarts (gives the restarted node time to catch up on its replicas; raise it for large data sets) |
| nameOverride | string | `""` | String to partially override the fullname template with a string (will prepend the release name) |
| networkPolicy.allowIntraCluster | bool | `true` | Allow ingress/egress traffic between the pods of this release (required for cluster communication) |
| networkPolicy.allowTests | bool | `true` | Allow ingress from the chart's test pods (helm test) |
| networkPolicy.create | bool | `false` | Create a NetworkPolicy |
| networkPolicy.egress | list | `[{"ports":[{"port":53,"protocol":"UDP"},{"port":53,"protocol":"TCP"}],"to":[{"ipBlock":{"cidr":"0.0.0.0/0"}}]},{"ports":[{"port":443,"protocol":"TCP"}],"to":[{"ipBlock":{"cidr":"0.0.0.0/0"}}]}]` | NetworkPolicy egress rules (a list set here replaces these defaults, so repeat the DNS rule in it) |
| networkPolicy.ingress | list | `[]` | NetworkPolicy ingress rules (add rules for clients that need access to the cluster) |
| networkPolicy.name | string | `""` | Name for the NetworkPolicy (defaults to fullname when empty) |
| nodeSelector | object | `{}` | Node selector |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Persistent volume access modes |
| persistence.annotations | object | `{}` | Annotations to add to the PersistentVolumeClaim |
| persistence.enabled | bool | `true` | Enable persistent settings (the volume keeps the work directory, with the cluster and metastorage state; without it, a restarted node loses that state) |
| persistence.labels | object | `{}` | Labels to add to the PersistentVolumeClaim |
| persistence.persistentVolumeClaimRetentionPolicy.enabled | bool | `false` | Enable persistent volume retention policy |
| persistence.persistentVolumeClaimRetentionPolicy.whenDeleted | string | `"Retain"` | Volume retention behavior that applies when the StatefulSet is deleted |
| persistence.persistentVolumeClaimRetentionPolicy.whenScaled | string | `"Retain"` | Volume retention behavior when the replica count of the StatefulSet is reduced |
| persistence.size | string | `"10Gi"` | Persistent volume size |
| persistence.storageClass | string | `""` | Persistent volume storage class (empty string uses cluster default) |
| podAnnotations | object | `{}` | Additional annotations to add to pods |
| podDisruptionBudget.create | bool | `true` | Create a PodDisruptionBudget (only with more than one replica) |
| podDisruptionBudget.maxUnavailable | int | `1` | Maximum number of pods that can be unavailable during disruptions (used when minAvailable is empty) |
| podDisruptionBudget.minAvailable | string | `""` | Minimum number of pods that must be available during disruptions (if set, used instead of maxUnavailable) |
| podLabels | object | `{}` | Additional labels to add to pods |
| podManagementPolicy | string | `"OrderedReady"` | StatefulSet pod management policy |
| podSecurityContext | object | `{"enabled":true,"fsGroup":1001,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001}` | Pod security context configuration |
| podSecurityContext.enabled | bool | `true` | Enable pod security context |
| priorityClassName | string | `""` | Pod priority class name |
| rbac.create | bool | `false` | Create RBAC items (e.g., role, role-binding) and mount the ServiceAccount token in the pods (not needed by Ignite, whose nodes find each other through the headless Service) |
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"tcpSocket":{"port":10300},"timeoutSeconds":10}` | Readiness probe configuration |
| readinessProbe.enabled | bool | `true` | Enable readiness probe |
| replicaCount | int | `1` | Number of pods |
| resources | object | `{"limits":{"cpu":"2","memory":"5Gi"},"requests":{"cpu":"2","memory":"5Gi"}}` | Main container requests/limits with guaranteed QoS (requests = limits)  memory calculation: onHeapMB (JVM Heap max size)   + maxMetaspaceSizeMB (JVM Metaspace max size)   + reservedCodeCacheSizeMB (JVM ReservedCodeCache size)   + offHeapMB (default storage profile max size; data + indexes (basic use cases will add a 30% increase on top of data))   + MIN(256MB, offHeapMB) (offHeapMB < 1 GB)     || offHeapMB/4 (offHeapMB between 1 GB and 8 GB)     || 2GB (offHeapMB > 8 GB)       (default storage profile checkpointing buffer size)   + ~512MB (other overheads; e.g., thread stacks, GC, symbols, etc.) |
| revisionHistoryLimit | int | `10` | Number of old StatefulSet revisions (ControllerRevisions) to retain |
| service.ports | object | `{"cluster":3344,"jmx":9404,"management":10300,"managementSsl":10400,"rest":10800}` | Service ports used by the Service spec. targetPort fields reference container.ports.* (cluster is on the headless Service only) |
| service.ports.management | int | `10300` | REST/Management API (HTTP) |
| service.ports.managementSsl | int | `10400` | REST/Management API (HTTPS) |
| service.ports.rest | int | `10800` | Client connector (binary protocol for thin clients and JDBC; not HTTP) |
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
| ssl.existingSecret | object | `{"keys":{"clientConnectorKsPass":"","clientConnectorTsPass":"","networkKsPass":"","networkTsPass":"","restKsPass":"","restTsPass":""},"name":""}` | Use an existing Secret for all SSL-related passphrase keys instead of a chart-managed Secret (not supported with SSL enabled yet, as Ignite 3 reads the passwords from its configuration only: see SECURITY.md) |
| ssl.existingSecret.keys | object | `{"clientConnectorKsPass":"","clientConnectorTsPass":"","networkKsPass":"","networkTsPass":"","restKsPass":"","restTsPass":""}` | Optional mapping to override the expected key names in the existing Secret |
| ssl.existingSecret.keys.clientConnectorKsPass | string | `""` | Key name for the client connector keystore password (defaults to 'client-connector-ks-pass') |
| ssl.existingSecret.keys.clientConnectorTsPass | string | `""` | Key name for the client connector truststore password (defaults to 'client-connector-ts-pass') |
| ssl.existingSecret.keys.networkKsPass | string | `""` | Key name for the network keystore password (defaults to 'network-ks-pass') |
| ssl.existingSecret.keys.networkTsPass | string | `""` | Key name for the network truststore password (defaults to 'network-ts-pass') |
| ssl.existingSecret.keys.restKsPass | string | `""` | Key name for the REST keystore password (defaults to 'rest-ks-pass') |
| ssl.existingSecret.keys.restTsPass | string | `""` | Key name for the REST truststore password (defaults to 'rest-ts-pass') |
| ssl.existingSecret.name | string | `""` | Name of the existing Secret containing SSL passphrase keys |
| ssl.manageSecret | bool | `true` | When true (default), the chart may create/manage its own Secret from values when no existingSecret is specified |
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
| startupProbe | object | `{"enabled":true,"failureThreshold":15,"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"tcpSocket":{"port":10300},"timeoutSeconds":1}` | Startup probe configuration |
| startupProbe.enabled | bool | `true` | Enable startup probe |
| terminationGracePeriodSeconds | int | `60` | Pod termination grace period |
| tolerations | list | `[]` | Node tolerations |
| topologySpreadConstraints | list | `[{"labelSelector":{"matchLabels":{"app.kubernetes.io/instance":"{{ .Release.Name }}","app.kubernetes.io/name":"{{ include \"ignite.name\" . }}"}},"maxSkew":1,"topologyKey":"kubernetes.io/hostname","whenUnsatisfiable":"ScheduleAnyway"}]` | Topology spread constraints (templated; by default, the pods prefer different Kubernetes nodes, so that a node failure takes as few replicas of the same partitions as possible) |
| updateStrategy | object | `{"rollingUpdate":{"partition":0},"type":"RollingUpdate"}` | StatefulSet update strategy |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
