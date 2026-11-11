{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "aspnetcore-ignite-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "aspnetcore-ignite-server.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "aspnetcore-ignite-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "aspnetcore-ignite-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "aspnetcore-ignite-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Fail early on values from an older chart (included by the labels, which every template renders first)
*/}}
{{- define "aspnetcore-ignite-server.checkValues" -}}
{{- if not (hasKey .Values.autoscaling "scaleUp") -}}
{{- fail "The values miss settings of this chart version (e.g., reused from an older release by helm upgrade --reuse-values): upgrade with --reset-then-reuse-values instead" -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "aspnetcore-ignite-server.labels" -}}
{{- include "aspnetcore-ignite-server.checkValues" . -}}
helm.sh/chart: {{ include "aspnetcore-ignite-server.chart" . }}
{{ include "aspnetcore-ignite-server.selectorLabels" . }}
{{- if .Values.labels }}
{{ include "common.tplvalues.render" (dict "value" .Values.labels "context" $) }}
{{- end }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Pod labels
*/}}
{{- define "aspnetcore-ignite-server.podLabels" -}}
{{ include "aspnetcore-ignite-server.selectorLabels" . }}
{{- if .Values.podLabels }}
{{ include "common.tplvalues.render" (dict "value" .Values.podLabels "context" $) }}
{{- end }}
{{- end -}}

{{/*
Test pod labels (without the selector labels, so that the Service, PDB and NetworkPolicy do not select the test pods)
*/}}
{{- define "aspnetcore-ignite-server.testLabels" -}}
{{- include "aspnetcore-ignite-server.checkValues" . -}}
helm.sh/chart: {{ include "aspnetcore-ignite-server.chart" . }}
app.kubernetes.io/name: {{ include "aspnetcore-ignite-server.name" . }}-test
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: test
{{- if .Values.labels }}
{{ include "common.tplvalues.render" (dict "value" .Values.labels "context" $) }}
{{- end }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common annotations
*/}}
{{- define "aspnetcore-ignite-server.annotations" -}}
{{- if .Values.annotations }}
{{ include "common.tplvalues.render" (dict "value" .Values.annotations "context" $) }}
{{- end }}
{{- end -}}

{{/*
Pod annotations
*/}}
{{- define "aspnetcore-ignite-server.podAnnotations" -}}
{{- if .Values.podAnnotations }}
{{ include "common.tplvalues.render" (dict "value" .Values.podAnnotations "context" $) }}
{{- end }}
{{- end -}}

{{/*
Return the proper image name
*/}}
{{- define "aspnetcore-ignite-server.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion | toString -}}
    {{- if .Values.global }}
        {{- if .Values.global.imageRegistry }}
            {{- $registryName = .Values.global.imageRegistry -}}
        {{- end }}
    {{- end }}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{/*
The Apache Ignite version of the image
*/}}
{{- define "aspnetcore-ignite-server.igniteVersion" -}}
{{- default (index .Chart.Annotations "ignite.apache.org/version") .Values.igniteVersion -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "aspnetcore-ignite-server.serviceAccountName" -}}
    {{- if .Values.serviceAccount.create -}}
        {{ default (include "aspnetcore-ignite-server.fullname" .) .Values.serviceAccount.name }}
    {{- else -}}
        {{ default "default" .Values.serviceAccount.name }}
    {{- end -}}
{{- end -}}

{{/*
ServiceAccount annotations
*/}}
{{- define "aspnetcore-ignite-server.serviceAccountAnnotations" -}}
{{- $annotations := dict -}}
{{- if .Values.serviceAccount.annotations }}
    {{- $annotations = merge $annotations (include "common.tplvalues.render" (dict "value" .Values.serviceAccount.annotations "context" $) | fromYaml) -}}
{{- end }}
{{- with (include "aspnetcore-ignite-server.annotations" .) }}
    {{- $annotations = merge $annotations (. | fromYaml) -}}
{{- end }}
{{- if gt (len $annotations) 0 }}
    {{- $annotations | toYaml -}}
{{- end }}
{{- end -}}

{{/*
The server settings the chart sets from its values
*/}}
{{- define "aspnetcore-ignite-server.derivedEnv" -}}
DEFAULT_ON_HEAP_MEMORY: {{ default 1024 .Values.memory.onHeapMB | quote }}
DEFAULT_OFF_HEAP_MEMORY: {{ required "A valid memory.offHeapMB is required!" .Values.memory.offHeapMB | quote }}
{{- with .Values.memory.maxMetaspaceSizeMB }}
JVM_MAX_METASPACE_MB: {{ . | quote }}
{{- end }}
{{- with .Values.memory.reservedCodeCacheSizeMB }}
JVM_RESERVED_CODE_CACHE_MB: {{ . | quote }}
{{- end }}
{{- with .Values.memory.g1HeapRegionSizeMB }}
JVM_G1_HEAP_REGION_MB: {{ . | quote }}
{{- end }}
{{- with .Values.memory.maxDirectMemorySizeMB }}
JVM_MAX_DIRECT_MEMORY_MB: {{ . | quote }}
{{- end }}
ENABLE_AUTHENTICATION: {{ .Values.authentication.enabled | quote }}
PEER_ASSEMBLY_LOADING: {{ .Values.peerAssemblyLoadingEnabled | quote }}
PEER_CLASS_LOADING_ENABLED: {{ .Values.peerClassLoadingEnabled | quote }}
{{- with .Values.sqlSchemas }}
SQL_SCHEMAS: {{ join "," . | quote }}
{{- end }}
{{- if not (has (toString .Values.sqlQueryHistorySize) (list "" "<nil>")) }}
SQL_QUERY_HISTORY_SIZE: {{ .Values.sqlQueryHistorySize | quote }}
{{- end }}
SPRING_EXTRA_BEANS_FILE: /app/config-extra/spring-extra-beans.xml
SPRING_EXTRA_PROPERTIES_FILE: /app/config-extra/spring-extra-properties.xml
{{- with .Values.timeouts.failureDetectionTimeout }}
FAILURE_DETECTION_TIMEOUT_MS: {{ . | quote }}
{{- end }}
{{- with .Values.timeouts.clientFailureDetectionTimeout }}
CLIENT_FAILURE_DETECTION_TIMEOUT_MS: {{ . | quote }}
{{- end }}
{{- with .Values.timeouts.networkTimeout }}
NETWORK_TIMEOUT_MS: {{ . | quote }}
{{- end }}
{{- with .Values.threadPools.publicThreadPoolSize }}
PUBLIC_THREAD_POOL_SIZE: {{ . | quote }}
{{- end }}
{{- with .Values.threadPools.systemThreadPoolSize }}
SYSTEM_THREAD_POOL_SIZE: {{ . | quote }}
{{- end }}
{{- with .Values.threadPools.queryThreadPoolSize }}
QUERY_THREAD_POOL_SIZE: {{ . | quote }}
{{- end }}
{{- with .Values.threadPools.serviceThreadPoolSize }}
SERVICE_THREAD_POOL_SIZE: {{ . | quote }}
{{- end }}
{{- with .Values.threadPools.stripedPoolSize }}
STRIPED_THREAD_POOL_SIZE: {{ . | quote }}
{{- end }}
{{- with .Values.threadPools.dataStreamerThreadPoolSize }}
DATA_STREAMER_THREAD_POOL_SIZE: {{ . | quote }}
{{- end }}
PERSISTENCE_ENABLED: {{ .Values.persistence.enabled | quote }}
{{- if and .Values.persistence.enabled .Values.persistence.walVolume.enabled }}
WAL_PATH: /wal
WAL_ARCHIVE_PATH: /wal/archive
{{- end }}
{{- with .Values.dataStorage.walMode }}
WAL_MODE: {{ . | quote }}
{{- end }}
WAL_COMPACTION_ENABLED: {{ .Values.dataStorage.walCompactionEnabled | quote }}
{{- with .Values.dataStorage.pageEvictionMode }}
PAGE_EVICTION_MODE: {{ . | quote }}
{{- end }}
USE_SSL: {{ .Values.ssl.enabled | quote }}
USE_CLIENT_SSL: {{ .Values.ssl.clientConnector.enabled | quote }}
SSL_CLIENT_AUTH: {{ .Values.ssl.clientConnector.clientAuth | quote }}
SSL_KEY_ALGORITHM: {{ .Values.ssl.keyAlgorithm | quote }}
SSL_KEY_STORE_TYPE: {{ .Values.ssl.keyStoreType | quote }}
SSL_TRUST_STORE_TYPE: {{ .Values.ssl.trustStoreType | quote }}
SSL_PROTOCOL: {{ .Values.ssl.protocol | quote }}
RESTART_ON_SSL_FILE_CHANGE: {{ .Values.ssl.restartOnFileChange | quote }}
{{- if .Values.ssl.storesSecret.name }}
SSL_KEY_STORE_FILE_PATH: {{ printf "/certs/%s" .Values.ssl.storesSecret.keyStoreKey | quote }}
SSL_TRUST_STORE_FILE_PATH: {{ printf "/certs/%s" .Values.ssl.storesSecret.trustStoreKey | quote }}
{{- with .Values.ssl.storesSecret.clientCertificateKey }}
SSL_CLIENT_CERTIFICATE_PATH: {{ printf "/certs/%s" . | quote }}
{{- end }}
{{- else }}
SSL_KEY_STORE_FILE_PATH: {{ .Values.ssl.keyStoreFilePath | quote }}
SSL_TRUST_STORE_FILE_PATH: {{ .Values.ssl.trustStoreFilePath | quote }}
SSL_CLIENT_CERTIFICATE_PATH: {{ .Values.ssl.clientConnector.clientCertificatePath | quote }}
{{- end }}
REST_ENABLED: {{ .Values.rest.enabled | quote }}
MANAGEMENT_PORT: {{ .Values.container.ports.management | quote }}
ENABLE_OFF_HEAP_METRICS: {{ .Values.metrics.enabled | quote }}
METRICS_PER_CACHE: {{ .Values.metrics.perCache | quote }}
{{- end -}}

{{/*
A password from an existing Secret or the chart-managed Secret <fullname>-<suffix> (optional, unless required is true)
*/}}
{{- define "aspnetcore-ignite-server.secretKeyRef" -}}
valueFrom:
  secretKeyRef:
    {{- if .existing }}
    name: {{ .existing }}
    key: {{ default .default .key }}
    {{- else }}
    name: {{ include "aspnetcore-ignite-server.fullname" .context }}-{{ .suffix }}
    key: {{ .default }}
    {{- end }}
    {{- if not .required }}
    optional: true
    {{- end }}
{{- end -}}
