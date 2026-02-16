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
Common labels
*/}}
{{- define "ignite.labels" -}}
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
{{- with (include "ignite.annotations" .) }}
    {{- $annotations = merge $annotations (. | fromYaml) -}}
{{- end }}
{{- if .Values.serviceAccount.annotations }}
    {{- $annotations = merge $annotations (include "common.tplvalues.render" (dict "value" .Values.serviceAccount.annotations "context" $) | fromYaml) -}}
{{- end }}
{{- if gt (len $annotations) 0 }}
    {{- $annotations | toYaml -}}
{{- end }}
{{- end -}}
