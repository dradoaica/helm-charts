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
{{- if not (hasKey .Values "logging") -}}
{{- fail "The values miss settings added in chart 2.19.3 (e.g., reused from a 2.19.2 release by helm upgrade --reuse-values): upgrade with --reset-then-reuse-values instead" -}}
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
{{- include "ignite.checkValues" . -}}
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
Activation job pod labels (without the selector labels, so that the Services do not route clients to the job pod and
the Kubernetes IP finder does not take it for a node)
*/}}
{{- define "ignite.activationJobLabels" -}}
app.kubernetes.io/name: {{ include "ignite.name" . }}-activate
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: cluster-activate
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
Return the proper activation job image name
*/}}
{{- define "ignite.activationJob.image" -}}
{{- $registryName := .Values.activationJob.image.registry -}}
{{- $repositoryName := .Values.activationJob.image.repository -}}
{{- $tag := .Values.activationJob.image.tag | toString -}}
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
