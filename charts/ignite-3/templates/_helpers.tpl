{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ignite.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ignite.fullname" -}}
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
{{- define "ignite.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "ignite.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ignite.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Fail early on values from an older chart (included by the labels, which every template renders first)
*/}}
{{- define "ignite.checkValues" -}}
{{- if not (hasKey .Values.autoscaling "scaleUp") -}}
{{- fail "The values miss settings of this chart version (e.g., reused from an older release by helm upgrade --reuse-values): upgrade with --reset-then-reuse-values instead" -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "ignite.labels" -}}
{{- include "ignite.checkValues" . -}}
helm.sh/chart: {{ include "ignite.chart" . }}
{{ include "ignite.selectorLabels" . }}
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
{{- define "ignite.podLabels" -}}
{{ include "ignite.selectorLabels" . }}
{{- if .Values.podLabels }}
{{ include "common.tplvalues.render" (dict "value" .Values.podLabels "context" $) }}
{{- end }}
{{- end -}}

{{/*
Test pod labels (without the selector labels, so that the Service, PDB and NetworkPolicy do not select the test pods)
*/}}
{{- define "ignite.testLabels" -}}
helm.sh/chart: {{ include "ignite.chart" . }}
app.kubernetes.io/name: {{ include "ignite.name" . }}-test
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
Initialization job pod labels (without the selector labels, so that the Services do not route clients to the job pod and
the nodes do not take it for one of theirs, the headless Service listing it)
*/}}
{{- define "ignite.initializationJobLabels" -}}
app.kubernetes.io/name: {{ include "ignite.name" . }}-init
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: cluster-init
{{- end -}}

{{/*
The G1 region size in MB: memory.g1HeapRegionSizeMB, or what the JVM would choose (about 2048 regions, a power of 2
from 1 to 32), since the image always passes -XX:G1HeapRegionSize (32 MB by default, too coarse for small heaps)
*/}}
{{- define "ignite.g1HeapRegionSizeMB" -}}
{{- $regionMB := 1 -}}
{{- $perRegion := div (int (default 1024 .Values.memory.onHeapMB)) 2048 -}}
{{- range list 2 4 8 16 32 -}}
{{- if ge $perRegion . }}{{ $regionMB = . }}{{ end -}}
{{- end -}}
{{- default $regionMB .Values.memory.g1HeapRegionSizeMB -}}
{{- end -}}

{{/*
Validate the values
*/}}
{{- define "ignite.validate" -}}
{{- if not (has .Values.dataStorage.engine (list "aipersist" "aimem" "rocksdb")) -}}
{{- fail (printf "dataStorage.engine %q is not one of aipersist, aimem or rocksdb" .Values.dataStorage.engine) -}}
{{- end -}}
{{- if and .Values.ssl.existingSecret.name (or .Values.ssl.clientConnector.enabled .Values.ssl.network.enabled .Values.ssl.rest.enabled) -}}
{{- fail "ssl.existingSecret is not supported yet: Ignite 3 reads the SSL passwords from its configuration only, which the chart renders from ssl.*.keyStorePassword and ssl.*.trustStorePassword (see SECURITY.md)" -}}
{{- end -}}
{{- if and .Values.jmx.enabled (not .Values.jmx.agent.sha256) -}}
{{- fail "jmx.agent.sha256 is required with jmx.enabled (the SHA-256 checksum of the jar at jmx.agent.url)" -}}
{{- end -}}
{{- end -}}

{{/*
Common annotations
*/}}
{{- define "ignite.annotations" -}}
{{- if .Values.annotations }}
{{ include "common.tplvalues.render" (dict "value" .Values.annotations "context" $) }}
{{- end }}
{{- end -}}

{{/*
Pod annotations
*/}}
{{- define "ignite.podAnnotations" -}}
{{- if .Values.podAnnotations }}
{{ include "common.tplvalues.render" (dict "value" .Values.podAnnotations "context" $) }}
{{- end }}
{{- end -}}

{{/*
Return the proper image name
*/}}
{{- define "ignite.image" -}}
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
Return the proper JMX agent image name
*/}}
{{- define "ignite.jmxAgent.image" -}}
{{- $registryName := .Values.jmx.agent.image.registry -}}
{{- $repositoryName := .Values.jmx.agent.image.repository -}}
{{- $tag := .Values.jmx.agent.image.tag | toString -}}
    {{- if .Values.global }}
        {{- if .Values.global.imageRegistry }}
            {{- $registryName = .Values.global.imageRegistry -}}
        {{- end }}
    {{- end }}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "ignite.serviceAccountName" -}}
    {{- if .Values.serviceAccount.create -}}
        {{ default (include "ignite.fullname" .) .Values.serviceAccount.name }}
    {{- else -}}
        {{ default "default" .Values.serviceAccount.name }}
    {{- end -}}
{{- end -}}

{{/*
ServiceAccount annotations
*/}}
{{- define "ignite.serviceAccountAnnotations" -}}
{{- $annotations := dict -}}
{{- if .Values.serviceAccount.annotations }}
    {{- $annotations = merge $annotations (include "common.tplvalues.render" (dict "value" .Values.serviceAccount.annotations "context" $) | fromYaml) -}}
{{- end }}
{{- with (include "ignite.annotations" .) }}
    {{- $annotations = merge $annotations (. | fromYaml) -}}
{{- end }}
{{- if gt (len $annotations) 0 }}
    {{- $annotations | toYaml -}}
{{- end }}
{{- end -}}
