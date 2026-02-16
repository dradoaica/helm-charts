{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "conductor-oss-conductor.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "conductor-oss-conductor.fullname" -}}
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
{{- define "conductor-oss-conductor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "conductor-oss-conductor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "conductor-oss-conductor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "conductor-oss-conductor.labels" -}}
helm.sh/chart: {{ include "conductor-oss-conductor.chart" . }}
{{ include "conductor-oss-conductor.selectorLabels" . }}
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
{{- define "conductor-oss-conductor.podLabels" -}}
{{ include "conductor-oss-conductor.selectorLabels" . }}
{{- if .Values.podLabels }}
{{ include "common.tplvalues.render" (dict "value" .Values.podLabels "context" $) }}
{{- end }}
{{- end -}}

{{/*
Common annotations
*/}}
{{- define "conductor-oss-conductor.annotations" -}}
{{- if .Values.annotations }}
{{ include "common.tplvalues.render" (dict "value" .Values.annotations "context" $) }}
{{- end }}
{{- end -}}

{{/*
Pod annotations
*/}}
{{- define "conductor-oss-conductor.podAnnotations" -}}
{{- if .Values.podAnnotations }}
{{ include "common.tplvalues.render" (dict "value" .Values.podAnnotations "context" $) }}
{{- end }}
{{- end -}}

{{/*
Return the proper image name
*/}}
{{- define "conductor-oss-conductor.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion | toString -}}
    {{- if .Values.global -}}
        {{- if .Values.global.imageRegistry -}}
            {{- $registryName = .Values.global.imageRegistry -}}
        {{- end -}}
    {{- end -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "conductor-oss-conductor.serviceAccountName" -}}
    {{- if .Values.serviceAccount.create -}}
        {{- default (include "conductor-oss-conductor.fullname" .) .Values.serviceAccount.name -}}
    {{- else -}}
        {{- default "default" .Values.serviceAccount.name -}}
    {{- end -}}
{{- end -}}

{{/*
ServiceAccount annotations
*/}}
{{- define "conductor-oss-conductor.serviceAccountAnnotations" -}}
{{- $annotations := dict -}}
{{- with (include "conductor-oss-conductor.annotations" .) -}}
    {{- $annotations = merge $annotations (. | fromYaml) -}}
{{- end -}}
{{- if .Values.serviceAccount.annotations -}}
    {{- $annotations = merge $annotations (include "common.tplvalues.render" (dict "value" .Values.serviceAccount.annotations "context" $) | fromYaml) -}}
{{- end -}}
{{- if gt (len $annotations) 0 -}}
    {{- $annotations | toYaml -}}
{{- end -}}
{{- end -}}
