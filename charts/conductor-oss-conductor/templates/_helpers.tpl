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
Fail early on values from an older chart (included by the labels, which every template renders first)
*/}}
{{- define "conductor-oss-conductor.checkValues" -}}
{{- if not (hasKey .Values "extraProperties") -}}
{{- fail "The values miss settings added in chart 3.33.2 (e.g., reused from a 3.33.1 release by helm upgrade --reuse-values): upgrade with --reset-then-reuse-values instead" -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "conductor-oss-conductor.labels" -}}
{{- include "conductor-oss-conductor.checkValues" . -}}
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
Test pod labels (without the selector labels, so that the Service, PDB and NetworkPolicy do not select the test pods)
*/}}
{{- define "conductor-oss-conductor.testLabels" -}}
{{- include "conductor-oss-conductor.checkValues" . -}}
helm.sh/chart: {{ include "conductor-oss-conductor.chart" . }}
app.kubernetes.io/name: {{ include "conductor-oss-conductor.name" . }}-test
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
Name of the Secret holding the credentials
*/}}
{{- define "conductor-oss-conductor.secretName" -}}
{{- .Values.secrets.existingSecret.name | default (include "conductor-oss-conductor.fullname" .) -}}
{{- end -}}

{{/*
Whether the chart creates the Secret holding the credentials
*/}}
{{- define "conductor-oss-conductor.createSecret" -}}
{{- if and (ne false .Values.secrets.manageSecret) (not .Values.secrets.existingSecret.name) -}}
true
{{- end -}}
{{- end -}}

{{/*
Whether a Redis connection is used
*/}}
{{- define "conductor-oss-conductor.usesRedis" -}}
{{- if or (hasPrefix "redis" .Values.db.type) (hasPrefix "redis" .Values.queue.type) (eq .Values.workflowExecutionLock.type "redis") -}}
true
{{- end -}}
{{- end -}}

{{/*
Whether the PostgreSQL connection (Spring datasource) is used
*/}}
{{- define "conductor-oss-conductor.usesPostgres" -}}
{{- if or (eq .Values.db.type "postgres") (eq .Values.externalPayloadStorage.type "postgres") -}}
true
{{- end -}}
{{- end -}}

{{/*
Whether Azure Blob external payload storage is used (azure_blob is the legacy chart value)
*/}}
{{- define "conductor-oss-conductor.usesAzureBlob" -}}
{{- if has .Values.externalPayloadStorage.type (list "azureblob" "azure_blob") -}}
true
{{- end -}}
{{- end -}}

{{/*
Enabled event queue systems as a YAML list (amqp, nats_stream, jsm, kafka): enabled explicitly or as the default event queue
*/}}
{{- define "conductor-oss-conductor.eventQueues" -}}
{{- $v := .Values -}}
{{- $enabled := dict "amqp" $v.amqpEventQueues.enabled "nats_stream" $v.natsEventQueues.natsStream.enabled "jsm" $v.natsEventQueues.jetStream.enabled "kafka" $v.kafkaEventQueues.enabled -}}
{{- range $type, $on := $enabled }}
{{- if or $on (and $v.defaultEventQueue.enabled (eq $v.defaultEventQueue.type $type)) }}
- {{ $type }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
TCP ports of the configured backends (Redis, the database, the indexing backend, the event queues), as a YAML list
*/}}
{{- define "conductor-oss-conductor.backendPorts" -}}
{{- $v := .Values -}}
{{- $ports := list -}}
{{- $urls := list -}}
{{- if eq (include "conductor-oss-conductor.usesRedis" .) "true" -}}
{{- range (include "conductor-oss-conductor.redisNodes" . | fromYamlArray) -}}
{{- $ports = append $ports (index (splitList ":" .) 1) -}}
{{- end -}}
{{- if or (eq $v.db.type "redis_sentinel") (eq $v.queue.type "redis_sentinel") -}}
{{- /* Conductor connects to the master returned by the Sentinel nodes */ -}}
{{- $ports = append $ports $v.redis.port -}}
{{- end -}}
{{- end -}}
{{- if eq $v.db.type "mysql" -}}
{{- $ports = append $ports $v.mySql.port -}}
{{- end -}}
{{- if eq (include "conductor-oss-conductor.usesPostgres" .) "true" -}}
{{- $ports = append $ports $v.postgres.port -}}
{{- end -}}
{{- if eq $v.db.type "cassandra" -}}
{{- $ports = append $ports $v.cassandra.port -}}
{{- end -}}
{{- if $v.indexing.enabled -}}
{{- if has $v.indexing.type (list "elasticsearch" "elasticsearch8") -}}
{{- $urls = concat $urls (splitList "," $v.elasticsearch.url) -}}
{{- else if has $v.indexing.type (list "opensearch2" "opensearch3") -}}
{{- $urls = concat $urls (splitList "," $v.openSearch.url) -}}
{{- end -}}
{{- end -}}
{{- $eventQueues := include "conductor-oss-conductor.eventQueues" . | fromYamlArray -}}
{{- if has "amqp" $eventQueues -}}
{{- $ports = append $ports $v.amqpEventQueues.port -}}
{{- end -}}
{{- if has "nats_stream" $eventQueues -}}
{{- $urls = concat $urls (splitList "," $v.natsEventQueues.natsStream.url) -}}
{{- end -}}
{{- if has "jsm" $eventQueues -}}
{{- $urls = concat $urls (splitList "," $v.natsEventQueues.jetStream.url) -}}
{{- end -}}
{{- if has "kafka" $eventQueues -}}
{{- range (splitList "," $v.kafkaEventQueues.bootstrapServers) -}}
{{- $ports = append $ports (last (splitList ":" (trim .))) -}}
{{- end -}}
{{- end -}}
{{- $defaultPorts := dict "http" 80 "https" 443 "nats" 4222 "tls" 4222 -}}
{{- range $urls -}}
{{- $url := trim . -}}
{{- if $url -}}
{{- if not (contains "://" $url) -}}
{{- $url = printf "http://%s" $url -}}
{{- end -}}
{{- $parsed := urlParse $url -}}
{{- $hostPort := splitList ":" $parsed.host -}}
{{- $ports = append $ports (ternary (last $hostPort) (get $defaultPorts $parsed.scheme | default 80) (gt (len $hostPort) 1)) -}}
{{- end -}}
{{- end -}}
{{- $numbers := list -}}
{{- range $ports -}}
{{- $numbers = append $numbers (int .) -}}
{{- end -}}
{{- range ($numbers | uniq) }}
- {{ . }}
{{- end }}
{{- end -}}

{{/*
Credentials as a YAML list of { key, override, value, required, used, env }:
  key: the key in the chart-managed Secret, also giving the environment variable name (e.g., redis-password -> REDIS_PASSWORD)
  override: the secrets.existingSecret.keys entry renaming the key in an existing Secret
  required: always referenced when used (otherwise, only when set in values or when using an existing Secret)
  env: the environment variable name read by Conductor's own application.properties (e.g., ${OPENAI_API_KEY:}), when the
    chart does not render the property itself
*/}}
{{- define "conductor-oss-conductor.credentialDefinitions" -}}
{{- $v := .Values -}}
{{- $redis := eq (include "conductor-oss-conductor.usesRedis" .) "true" -}}
{{- $postgres := eq (include "conductor-oss-conductor.usesPostgres" .) "true" -}}
{{- $azureBlob := eq (include "conductor-oss-conductor.usesAzureBlob" .) "true" -}}
{{- $indexing := $v.indexing.enabled -}}
{{- $ai := $v.ai.enabled -}}
- { key: redis-password, override: redisPassword, value: {{ $v.redis.password | toJson }}, required: true, used: {{ $redis }} }
- { key: redis-sentinel-password, override: redisSentinelPassword, value: {{ $v.redis.sentinelPassword | toJson }}, used: {{ or (eq $v.db.type "redis_sentinel") (eq $v.queue.type "redis_sentinel") }} }
- { key: my-sql-password, override: mySqlPassword, value: {{ $v.mySql.password | toJson }}, required: true, used: {{ eq $v.db.type "mysql" }} }
- { key: postgres-password, override: postgresPassword, value: {{ $v.postgres.password | toJson }}, required: true, used: {{ $postgres }} }
- { key: cassandra-password, override: cassandraPassword, value: {{ $v.cassandra.password | toJson }}, used: {{ eq $v.db.type "cassandra" }} }
- { key: elasticsearch-password, override: elasticsearchPassword, value: {{ $v.elasticsearch.password | toJson }}, used: {{ and $indexing (has $v.indexing.type (list "elasticsearch" "elasticsearch8")) }} }
- { key: open-search-password, override: openSearchPassword, value: {{ $v.openSearch.password | toJson }}, used: {{ and $indexing (has $v.indexing.type (list "opensearch2" "opensearch3")) }} }
- { key: azure-blob-connection-string, override: azureBlobConnectionString, value: {{ $v.azureBlob.externalPayloadStorage.connectionString | toJson }}, used: {{ $azureBlob }} }
- { key: azure-blob-sas-token, override: azureBlobSasToken, value: {{ $v.azureBlob.externalPayloadStorage.sasToken | toJson }}, used: {{ $azureBlob }} }
- { key: amqp-password, override: amqpPassword, value: {{ $v.amqpEventQueues.password | toJson }}, used: {{ has "amqp" (include "conductor-oss-conductor.eventQueues" . | fromYamlArray) }} }
- { key: ai-decision-api-key, override: aiDecisionApiKey, value: {{ $v.ai.decision.apiKey | toJson }}, used: {{ $ai }}, env: DECISION_API_KEY }
- { key: ai-open-ai-api-key, override: aiOpenAiApiKey, value: {{ $v.ai.openAI.apiKey | toJson }}, used: {{ $ai }}, env: OPENAI_API_KEY }
- { key: ai-anthropic-api-key, override: aiAnthropicApiKey, value: {{ $v.ai.anthropic.apiKey | toJson }}, used: {{ $ai }}, env: ANTHROPIC_API_KEY }
- { key: ai-mistral-api-key, override: aiMistralApiKey, value: {{ $v.ai.mistral.apiKey | toJson }}, used: {{ $ai }}, env: MISTRAL_API_KEY }
- { key: ai-cohere-api-key, override: aiCohereApiKey, value: {{ $v.ai.cohere.apiKey | toJson }}, used: {{ $ai }}, env: COHERE_API_KEY }
- { key: ai-grok-api-key, override: aiGrokApiKey, value: {{ $v.ai.grok.apiKey | toJson }}, used: {{ $ai }}, env: XAI_API_KEY }
- { key: ai-perplexity-api-key, override: aiPerplexityApiKey, value: {{ $v.ai.perplexity.apiKey | toJson }}, used: {{ $ai }}, env: PERPLEXITY_API_KEY }
- { key: ai-hugging-face-api-key, override: aiHuggingFaceApiKey, value: {{ $v.ai.huggingFace.apiKey | toJson }}, used: {{ $ai }}, env: HUGGINGFACE_API_KEY }
- { key: ai-stability-ai-api-key, override: aiStabilityAiApiKey, value: {{ $v.ai.stabilityAI.apiKey | toJson }}, used: {{ $ai }}, env: STABILITY_API_KEY }
- { key: ai-azure-open-ai-api-key, override: aiAzureOpenAiApiKey, value: {{ $v.ai.azureOpenAI.apiKey | toJson }}, used: {{ $ai }}, env: AZURE_OPENAI_API_KEY }
- { key: ai-bedrock-access-key, override: aiBedrockAccessKey, value: {{ $v.ai.bedrock.accessKey | toJson }}, used: {{ $ai }} }
- { key: ai-bedrock-secret-key, override: aiBedrockSecretKey, value: {{ $v.ai.bedrock.secretKey | toJson }}, used: {{ $ai }} }
- { key: ai-bedrock-bearer-token, override: aiBedrockBearerToken, value: {{ $v.ai.bedrock.bearerToken | toJson }}, used: {{ $ai }} }
- { key: ai-gemini-api-key, override: aiGeminiApiKey, value: {{ $v.ai.gemini.apiKey | toJson }}, used: {{ $ai }}, env: GEMINI_API_KEY }
- { key: datadog-api-key, override: datadogApiKey, value: {{ $v.management.metricsExport.datadogApiKey | toJson }}, used: {{ $v.management.metricsExport.datadog }} }
- { key: azure-monitor-instrumentation-key, override: azureMonitorInstrumentationKey, value: {{ $v.management.metricsExport.azureMonitorInstrumentationKey | toJson }}, used: {{ $v.management.metricsExport.azureMonitor }} }
{{- end -}}

{{/*
Credentials referenced by the pods, as a YAML list of { key, secretKey, env, value, optional }
*/}}
{{- define "conductor-oss-conductor.credentials" -}}
{{- $external := not (include "conductor-oss-conductor.createSecret" .) -}}
{{- $keys := .Values.secrets.existingSecret.keys -}}
{{- range (include "conductor-oss-conductor.credentialDefinitions" . | fromYamlArray) }}
{{- if and .used (or .required .value $external) }}
- key: {{ .key }}
  secretKey: {{ (and $.Values.secrets.existingSecret.name (get $keys .override)) | default .key }}
  env: {{ .env | default (.key | replace "-" "_" | upper) }}
  value: {{ .value | default "" | toJson }}
  optional: {{ and $external (not .required) }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Property placeholder for a credential (empty when the credential is not referenced)
Usage: include "conductor-oss-conductor.credential" (dict "key" "redis-password" "context" $)
*/}}
{{- define "conductor-oss-conductor.credential" -}}
{{- $key := .key -}}
{{- range (include "conductor-oss-conductor.credentials" .context | fromYamlArray) -}}
{{- if eq .key $key -}}
{{- printf "${%s%s}" .env (ternary ":" "" .optional) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Path of the Google application credentials for Gemini (the mounted Secret, or ai.gemini.applicationCredentials)
*/}}
{{- define "conductor-oss-conductor.geminiCredentialsPath" -}}
{{- if .Values.ai.enabled -}}
{{- if .Values.ai.gemini.credentialsSecret.name -}}
/var/run/secrets/gemini/credentials.json
{{- else -}}
{{- .Values.ai.gemini.applicationCredentials -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Redis nodes as a YAML list of host:port:rack
*/}}
{{- define "conductor-oss-conductor.redisNodes" -}}
{{- $redis := .Values.redis -}}
{{- range (splitList ";" ($redis.hosts | default (printf "%s:%v" $redis.host $redis.port))) }}
{{- $node := trim . }}
{{- if $node }}
{{- $parts := splitList ":" $node }}
{{- if or (lt (len $parts) 2) (not (first $parts)) }}
{{- fail (printf "redis.hosts entry %q is not host:port[:rack]" $node) }}
{{- end }}
{{- $rack := $redis.availabilityZone }}
{{- if gt (len $parts) 2 }}
{{- $rack = index $parts 2 }}
{{- end }}
- {{ printf "%s:%s:%s" (index $parts 0) (index $parts 1) $rack | quote }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Redis lock (Redisson) server type: single, cluster or sentinel
*/}}
{{- define "conductor-oss-conductor.redisLockServerType" -}}
{{- $type := ternary .Values.db.type .Values.queue.type (hasPrefix "redis" .Values.db.type) -}}
{{- .Values.redisLock.serverType | default (ternary "cluster" (ternary "sentinel" "single" (eq $type "redis_sentinel")) (eq $type "redis_cluster")) | lower -}}
{{- end -}}

{{/*
Redis lock (Redisson) server address(es): one for single, comma-separated for cluster, semicolon-separated for sentinel
*/}}
{{- define "conductor-oss-conductor.redisLockServerAddress" -}}
{{- $scheme := ternary "rediss" "redis" (eq (toString .Values.redis.ssl) "true") -}}
{{- $addresses := list -}}
{{- range (include "conductor-oss-conductor.redisNodes" . | fromYamlArray) -}}
{{- $parts := splitList ":" . -}}
{{- $addresses = append $addresses (printf "%s://%s:%s" $scheme (index $parts 0) (index $parts 1)) -}}
{{- end -}}
{{- $serverType := include "conductor-oss-conductor.redisLockServerType" . -}}
{{- if eq $serverType "cluster" -}}
{{- join "," $addresses -}}
{{- else if eq $serverType "sentinel" -}}
{{- join ";" $addresses -}}
{{- else -}}
{{- first $addresses -}}
{{- end -}}
{{- end -}}

{{/*
Validate the values
*/}}
{{- define "conductor-oss-conductor.validate" -}}
{{- $v := .Values -}}
{{- $types := dict
  "db.type" (list $v.db.type (list "redis_standalone" "redis_cluster" "redis_sentinel" "mysql" "postgres" "cassandra" "sqlite"))
  "queue.type" (list $v.queue.type (list "redis_standalone" "redis_cluster" "redis_sentinel" "mysql" "postgres" "sqlite"))
  "workflowExecutionLock.type" (list $v.workflowExecutionLock.type (list "redis" "postgres" "sqlite" "local_only" "noop_lock"))
  "indexing.type" (list $v.indexing.type (list "elasticsearch" "elasticsearch8" "opensearch2" "opensearch3" "postgres" "sqlite"))
  "externalPayloadStorage.type" (list ($v.externalPayloadStorage.type | default "") (list "" "postgres" "s3" "azureblob" "azure_blob"))
  "defaultEventQueue.type" (list $v.defaultEventQueue.type (list "amqp" "nats_stream" "jsm" "kafka"))
}}
{{- range $name, $check := $types -}}
{{- if not (has (first $check) (last $check)) -}}
{{- if and (eq $name "db.type") (eq (first $check) "memory") -}}
{{- fail "db.type memory does not start with Conductor 3.33 (use sqlite for a self-contained pod)" -}}
{{- else if and (eq $name "indexing.type") (eq (first $check) "opensearch") -}}
{{- fail "indexing.type opensearch is no longer supported by Conductor: use opensearch2 or opensearch3" -}}
{{- end -}}
{{- fail (printf "%s %q is not one of %s" $name (first $check) (last $check | toJson)) -}}
{{- end -}}
{{- end -}}
{{- if and (not (hasPrefix "redis" $v.queue.type)) (ne $v.queue.type $v.db.type) -}}
{{- fail (printf "queue.type %s requires the same db.type (or use a Redis queue.type)" $v.queue.type) -}}
{{- end -}}
{{- range $setting := list "indexing.type" "workflowExecutionLock.type" -}}
{{- $type := ternary $v.indexing.type $v.workflowExecutionLock.type (eq $setting "indexing.type") -}}
{{- if and (has $type (list "postgres" "sqlite")) (ne $type $v.db.type) -}}
{{- fail (printf "%s %s requires the same db.type" $setting $type) -}}
{{- end -}}
{{- end -}}
{{- if regexMatch "[:;]" (toString $v.redis.password) -}}
{{- fail "redis.password must not contain ':' or ';', as Conductor reads it from the Redis host list" -}}
{{- end -}}
{{- if and $v.autoscaling.create (not $v.autoscaling.targetCPUUtilizationPercentage) (not $v.autoscaling.targetMemoryUtilizationPercentage) -}}
{{- fail "autoscaling.create requires autoscaling.targetCPUUtilizationPercentage or autoscaling.targetMemoryUtilizationPercentage" -}}
{{- end -}}
{{- if and $v.workflowArchival.enabled (eq $v.workflowArchival.type "S3") (not $v.workflowArchival.s3BucketName) -}}
{{- fail "workflowArchival.s3BucketName is required with workflowArchival.type S3" -}}
{{- end -}}
{{- if and (eq (include "conductor-oss-conductor.usesRedis" .) "true") (not $v.redis.host) (not $v.redis.hosts) -}}
{{- fail "redis.host (or redis.hosts) is required with the configured db.type, queue.type or workflowExecutionLock.type" -}}
{{- end -}}
{{- if and (eq $v.db.type "redis_sentinel") (not $v.redis.masterName) -}}
{{- fail "redis.masterName is required with db.type redis_sentinel" -}}
{{- end -}}
{{- if and (eq (include "conductor-oss-conductor.usesPostgres" .) "true") (or (not $v.postgres.host) (not $v.postgres.database)) -}}
{{- fail "postgres.host and postgres.database are required with db.type or externalPayloadStorage.type postgres" -}}
{{- end -}}
{{- if eq $v.db.type "mysql" -}}
{{- if or (not $v.mySql.host) (not $v.mySql.database) -}}
{{- fail "mySql.host and mySql.database are required with db.type mysql" -}}
{{- end -}}
{{- if eq $v.externalPayloadStorage.type "postgres" -}}
{{- fail "externalPayloadStorage.type postgres cannot be used with db.type mysql, as both use the Spring datasource" -}}
{{- end -}}
{{- end -}}
{{- if and (eq $v.db.type "cassandra") (not $v.cassandra.contactPoints) -}}
{{- fail "cassandra.contactPoints is required with db.type cassandra" -}}
{{- end -}}
{{- if and $v.indexing.enabled (has $v.indexing.type (list "elasticsearch" "elasticsearch8")) (not $v.elasticsearch.url) -}}
{{- fail "elasticsearch.url is required with indexing.type elasticsearch (or set indexing.enabled to false)" -}}
{{- end -}}
{{- if and $v.indexing.enabled (has $v.indexing.type (list "opensearch2" "opensearch3")) (not $v.openSearch.url) -}}
{{- fail "openSearch.url is required with indexing.type opensearch2 or opensearch3" -}}
{{- end -}}
{{- if and (eq $v.externalPayloadStorage.type "s3") (not $v.s3.externalPayloadStorage.bucketName) -}}
{{- fail "s3.externalPayloadStorage.bucketName is required with externalPayloadStorage.type s3" -}}
{{- end -}}
{{- if and (has "amqp" (include "conductor-oss-conductor.eventQueues" . | fromYamlArray)) (not $v.amqpEventQueues.hosts) -}}
{{- fail "amqpEventQueues.hosts is required with the AMQP event queues" -}}
{{- end -}}
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
{{- if .Values.serviceAccount.annotations -}}
    {{- $annotations = merge $annotations (include "common.tplvalues.render" (dict "value" .Values.serviceAccount.annotations "context" $) | fromYaml) -}}
{{- end -}}
{{- with (include "conductor-oss-conductor.annotations" .) -}}
    {{- $annotations = merge $annotations (. | fromYaml) -}}
{{- end -}}
{{- if gt (len $annotations) 0 -}}
    {{- $annotations | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
Conductor/Spring properties as a YAML map; empty values are left out (Conductor then uses its own defaults)
*/}}
{{- define "conductor-oss-conductor.properties" -}}
{{- $v := .Values -}}
{{- $credential := dict "context" . -}}
server.port: {{ $v.container.ports.rest | toJson }}
server.shutdown: graceful
spring.lifecycle.timeout-per-shutdown-phase: {{ $v.gracefulShutdownTimeout | toJson }}
spring.application.name: {{ $v.spring.applicationName | toJson }}
spring.main.allow-bean-definition-overriding: {{ $v.spring.allowBeanDefinitionOverriding | toJson }}
springdoc.api-docs.path: {{ $v.spring.apiDocsPath | toJson }}
logging.level.root: {{ $v.logging.level.root | toJson }}
{{- /* App */}}
conductor.app.stack: {{ $v.app.stack | toJson }}
conductor.app.appId: {{ $v.app.appID | toJson }}
conductor.app.executorServiceMaxThreadCount: {{ $v.app.executorServiceMaxThreadCount | toJson }}
conductor.app.workflowOffsetTimeout: {{ $v.app.workflowOffsetTimeout | toJson }}
conductor.app.maxPostponeDurationSeconds: {{ $v.app.maxPostponeDurationSeconds | toJson }}
conductor.app.sweeperThreadCount: {{ $v.app.sweeperThreadCount | toJson }}
conductor.app.sweeperWorkflowPollTimeout: {{ $v.app.sweeperWorkflowPollTimeout | toJson }}
conductor.app.sweeper.sweepBatchSize: {{ $v.app.sweeperSweepBatchSize | toJson }}
conductor.app.sweeper.queuePopTimeout: {{ $v.app.sweeperQueuePopTimeout | toJson }}
conductor.app.eventProcessorThreadCount: {{ $v.app.eventProcessorThreadCount | toJson }}
conductor.app.eventMessageIndexingEnabled: {{ $v.app.eventMessageIndexingEnabled | toJson }}
conductor.app.eventExecutionIndexingEnabled: {{ $v.app.eventExecutionIndexingEnabled | toJson }}
conductor.app.workflowExecutionLockEnabled: {{ $v.app.workflowExecutionLockEnabled | toJson }}
conductor.app.lockLeaseTime: {{ $v.app.lockLeaseTime | toJson }}
conductor.app.lockTimeToTry: {{ $v.app.lockTimeToTry | toJson }}
conductor.app.activeWorkerLastPollTimeout: {{ $v.app.activeWorkerLastPollTimeout | toJson }}
conductor.app.taskExecutionPostponeDuration: {{ $v.app.taskExecutionPostponeDuration | toJson }}
conductor.app.taskIndexingEnabled: {{ $v.app.taskIndexingEnabled | toJson }}
conductor.app.taskExecLogIndexingEnabled: {{ $v.app.taskExecLogIndexingEnabled | toJson }}
conductor.app.asyncIndexingEnabled: {{ $v.app.asyncIndexingEnabled | toJson }}
conductor.app.systemTaskWorkerThreadCount: {{ $v.app.systemTaskWorkerThreadCount | toJson }}
conductor.app.systemTaskMaxPollCount: {{ $v.app.systemTaskMaxPollCount | toJson }}
conductor.app.systemTaskWorkerCallbackDuration: {{ $v.app.systemTaskWorkerCallbackDuration | toJson }}
conductor.app.systemTaskWorkerPollInterval: {{ $v.app.systemTaskWorkerPollInterval | toJson }}
conductor.app.systemTaskQueuePopTimeout: {{ $v.app.systemTaskQueuePopTimeout | toJson }}
conductor.app.systemTaskWorkerExecutionNamespace: {{ $v.app.systemTaskWorkerExecutionNamespace | toJson }}
conductor.app.isolatedSystemTaskWorkerThreadCount: {{ $v.app.isolatedSystemTaskWorkerThreadCount | toJson }}
conductor.app.systemTaskPostponeThreshold: {{ $v.app.systemTaskPostponeThreshold | toJson }}
conductor.app.asyncUpdateShortRunningWorkflowDuration: {{ $v.app.asyncUpdateShortRunningWorkflowDuration | toJson }}
conductor.app.asyncUpdateDelay: {{ $v.app.asyncUpdateDelay | toJson }}
conductor.app.ownerEmailMandatory: {{ $v.app.ownerEmailMandatory | toJson }}
conductor.app.eventQueueSchedulerPollThreadCount: {{ $v.app.eventQueueSchedulerPollThreadCount | toJson }}
conductor.app.eventQueuePollInterval: {{ $v.app.eventQueuePollInterval | toJson }}
conductor.app.eventQueuePollCount: {{ $v.app.eventQueuePollCount | toJson }}
conductor.app.eventQueueLongPollTimeout: {{ $v.app.eventQueueLongPollTimeout | toJson }}
conductor.app.workflowInputPayloadSizeThreshold: {{ $v.app.workflowInputPayloadSizeThreshold | toJson }}
conductor.app.maxWorkflowInputPayloadSizeThreshold: {{ $v.app.maxWorkflowInputPayloadSizeThreshold | toJson }}
conductor.app.workflowOutputPayloadSizeThreshold: {{ $v.app.workflowOutputPayloadSizeThreshold | toJson }}
conductor.app.maxWorkflowOutputPayloadSizeThreshold: {{ $v.app.maxWorkflowOutputPayloadSizeThreshold | toJson }}
conductor.app.taskInputPayloadSizeThreshold: {{ $v.app.taskInputPayloadSizeThreshold | toJson }}
conductor.app.maxTaskInputPayloadSizeThreshold: {{ $v.app.maxTaskInputPayloadSizeThreshold | toJson }}
conductor.app.taskOutputPayloadSizeThreshold: {{ $v.app.taskOutputPayloadSizeThreshold | toJson }}
conductor.app.maxTaskOutputPayloadSizeThreshold: {{ $v.app.maxTaskOutputPayloadSizeThreshold | toJson }}
conductor.app.maxWorkflowVariablesPayloadSizeThreshold: {{ $v.app.maxWorkflowVariablesPayloadSizeThreshold | toJson }}
conductor.app.taskExecLogSizeLimit: {{ $v.app.taskExecLogSizeLimit | toJson }}
{{- range $task, $config := $v.app.taskWorkerConfigs }}
{{- range $name, $value := $config }}
{{ printf "conductor.app.taskWorkerConfigs.%s.%s" $task $name }}: {{ $value | toJson }}
{{- end }}
{{- end }}
conductor.app.workflow.name-validation.enabled: {{ $v.app.workflowNameValidationEnabled | toJson }}
conductor.app.summary-input-output-json-serialization.enabled: {{ $v.app.summaryInputOutputJsonSerializationEnabled | toJson }}
conductor.workflow-repair-service.enabled: {{ $v.app.workflowRepairServiceEnabled | toJson }}
conductor.scheduler.enabled: {{ $v.scheduler.enabled | toJson }}
{{- if $v.workflowMessageQueue.enabled }}
conductor.workflow-message-queue.enabled: true
conductor.workflow-message-queue.maxQueueSize: {{ $v.workflowMessageQueue.maxQueueSize | toJson }}
conductor.workflow-message-queue.ttlSeconds: {{ $v.workflowMessageQueue.ttlSeconds | toJson }}
conductor.workflow-message-queue.maxBatchSize: {{ $v.workflowMessageQueue.maxBatchSize | toJson }}
{{- end }}
{{- /* Persistence, queues, locking and indexing */}}
conductor.db.type: {{ $v.db.type | toJson }}
conductor.queue.type: {{ $v.queue.type | toJson }}
{{- if $v.defaultEventQueue.enabled }}
conductor.default-event-queue.type: {{ $v.defaultEventQueue.type | toJson }}
{{- end }}
conductor.workflow-execution-lock.type: {{ $v.workflowExecutionLock.type | toJson }}
conductor.indexing.enabled: {{ $v.indexing.enabled | toJson }}
conductor.indexing.type: {{ $v.indexing.type | toJson }}
{{- if eq (include "conductor-oss-conductor.usesRedis" .) "true" }}
{{- $password := include "conductor-oss-conductor.credential" (set $credential "key" "redis-password") }}
{{- $nodes := list }}
{{- range (include "conductor-oss-conductor.redisNodes" . | fromYamlArray) }}
{{- $nodes = append $nodes (printf "%s:%s" . $password) }}
{{- end }}
conductor.redis.hosts: {{ join ";" $nodes | toJson }}
conductor.redis.user: {{ $v.redis.username | toJson }}
conductor.redis.sentinelMasterName: {{ $v.redis.masterName | toJson }}
conductor.redis.sentinelPassword: {{ include "conductor-oss-conductor.credential" (set $credential "key" "redis-sentinel-password") | toJson }}
conductor.redis.ssl: {{ $v.redis.ssl | toJson }}
conductor.redis.taskDefCacheRefreshInterval: {{ $v.redis.taskDefCacheRefreshInterval | toJson }}
conductor.redis.workflowNamespacePrefix: {{ $v.redis.workflowNamespacePrefix | toJson }}
conductor.redis.queueNamespacePrefix: {{ $v.redis.queueNamespacePrefix | toJson }}
conductor.redis.availabilityZone: {{ $v.redis.availabilityZone | toJson }}
conductor.redis.maxIdleConnections: {{ $v.redis.maxIdleConnections | toJson }}
conductor.redis.minIdleConnections: {{ $v.redis.minIdleConnections | toJson }}
conductor.redis.minEvictableIdleTimeMillis: {{ $v.redis.minEvictableIdleTimeMillis | toJson }}
conductor.redis.timeBetweenEvictionRunsMillis: {{ $v.redis.timeBetweenEvictionRunsMillis | toJson }}
conductor.redis.testWhileIdle: {{ $v.redis.testWhileIdle | toJson }}
conductor.redis.numTestsPerEvictionRun: {{ $v.redis.numTestsPerEvictionRun | toJson }}
{{- if eq $v.workflowExecutionLock.type "redis" }}
conductor.redis-lock.serverType: {{ include "conductor-oss-conductor.redisLockServerType" . | toJson }}
conductor.redis-lock.serverAddress: {{ include "conductor-oss-conductor.redisLockServerAddress" . | toJson }}
conductor.redis-lock.serverUsername: {{ $v.redis.username | toJson }}
{{- if or $v.redis.password (not (include "conductor-oss-conductor.createSecret" .)) }}
conductor.redis-lock.serverPassword: {{ $password | toJson }}
{{- end }}
conductor.redis-lock.serverMasterName: {{ $v.redisLock.serverMasterName | default $v.redis.masterName | toJson }}
conductor.redis-lock.namespace: {{ $v.redisLock.namespace | toJson }}
{{- end }}
{{- end }}
{{- if eq $v.db.type "sqlite" }}
{{- /* The image's default database file is in /app/libs, which is read-only */}}
spring.datasource.url: "jdbc:sqlite:/tmp/conductor.db?busy_timeout=15000&journal_mode=WAL"
{{- end }}
{{- if eq $v.db.type "mysql" }}
spring.datasource.url: {{ printf "jdbc:mysql://%s:%v/%s%s" $v.mySql.host $v.mySql.port $v.mySql.database (ternary (printf "?%s" (trimPrefix "?" $v.mySql.urlParameters)) "" (not (empty $v.mySql.urlParameters))) | toJson }}
spring.datasource.username: {{ $v.mySql.username | toJson }}
spring.datasource.password: {{ include "conductor-oss-conductor.credential" (set $credential "key" "my-sql-password") | toJson }}
conductor.mysql.deadlockRetryMax: {{ $v.mySql.deadlockRetryMax | toJson }}
conductor.mysql.taskDefCacheRefreshInterval: {{ $v.mySql.taskDefCacheRefreshInterval | toJson }}
{{- end }}
{{- if eq (include "conductor-oss-conductor.usesPostgres" .) "true" }}
{{- $url := printf "jdbc:postgresql://%s:%v/%s%s" $v.postgres.host $v.postgres.port $v.postgres.database (ternary (printf "?%s" (trimPrefix "?" $v.postgres.urlParameters)) "" (not (empty $v.postgres.urlParameters))) }}
{{- $password := include "conductor-oss-conductor.credential" (set $credential "key" "postgres-password") }}
spring.datasource.url: {{ $url | toJson }}
spring.datasource.username: {{ $v.postgres.username | toJson }}
spring.datasource.password: {{ $password | toJson }}
conductor.postgres.schema: {{ $v.postgres.schema | toJson }}
conductor.postgres.deadlockRetryMax: {{ $v.postgres.deadlockRetryMax | toJson }}
conductor.postgres.taskDefCacheRefreshInterval: {{ $v.postgres.taskDefCacheRefreshInterval | toJson }}
conductor.postgres.asyncMaxPoolSize: {{ $v.postgres.asyncMaxPoolSize | toJson }}
conductor.postgres.asyncWorkerQueueSize: {{ $v.postgres.asyncWorkerQueueSize | toJson }}
conductor.postgres.pollDataFlushInterval: {{ $v.postgres.pollDataFlushInterval | toJson }}
conductor.postgres.pollDataCacheValidityPeriod: {{ $v.postgres.pollDataCacheValidityPeriod | toJson }}
conductor.postgres.onlyIndexOnStatusChange: {{ $v.postgres.onlyIndexOnStatusChange | toJson }}
conductor.postgres.experimentalQueueNotify: {{ $v.postgres.experimentalQueueNotify | toJson }}
conductor.postgres.experimentalQueueNotifyStalePeriod: {{ $v.postgres.experimentalQueueNotifyStalePeriod | toJson }}
{{- if eq $v.externalPayloadStorage.type "postgres" }}
conductor.external-payload-storage.type: postgres
conductor.external-payload-storage.postgres.conductor-url: {{ $v.postgres.externalPayloadStorage.conductorUrl | toJson }}
conductor.external-payload-storage.postgres.url: {{ $url | toJson }}
conductor.external-payload-storage.postgres.username: {{ $v.postgres.username | toJson }}
conductor.external-payload-storage.postgres.password: {{ $password | toJson }}
conductor.external-payload-storage.postgres.table-name: {{ $v.postgres.externalPayloadStorage.tableName | toJson }}
conductor.external-payload-storage.postgres.max-data-rows: {{ $v.postgres.externalPayloadStorage.maxDataRows | toString | toJson }}
conductor.external-payload-storage.postgres.max-data-days: {{ $v.postgres.externalPayloadStorage.maxDataDays | toJson }}
conductor.external-payload-storage.postgres.max-data-months: {{ $v.postgres.externalPayloadStorage.maxDataMonths | toJson }}
conductor.external-payload-storage.postgres.max-data-years: {{ $v.postgres.externalPayloadStorage.maxDataYears | toJson }}
{{- end }}
{{- end }}
{{- if eq $v.db.type "cassandra" }}
conductor.cassandra.hostAddress: {{ $v.cassandra.contactPoints | toJson }}
conductor.cassandra.port: {{ $v.cassandra.port | toJson }}
conductor.cassandra.keyspace: {{ $v.cassandra.keyspace | toJson }}
conductor.cassandra.username: {{ $v.cassandra.username | toJson }}
conductor.cassandra.password: {{ include "conductor-oss-conductor.credential" (set $credential "key" "cassandra-password") | toJson }}
{{- end }}
{{- if and $v.indexing.enabled (has $v.indexing.type (list "elasticsearch" "elasticsearch8")) }}
conductor.elasticsearch.url: {{ $v.elasticsearch.url | toJson }}
conductor.elasticsearch.username: {{ $v.elasticsearch.username | toJson }}
conductor.elasticsearch.password: {{ include "conductor-oss-conductor.credential" (set $credential "key" "elasticsearch-password") | toJson }}
conductor.elasticsearch.indexPrefix: {{ $v.elasticsearch.indexPrefix | toJson }}
conductor.elasticsearch.indexShardCount: {{ $v.elasticsearch.indexShardCount | toJson }}
conductor.elasticsearch.indexReplicasCount: {{ $v.elasticsearch.indexReplicasCount | toJson }}
conductor.elasticsearch.indexBatchSize: {{ $v.elasticsearch.indexBatchSize | toJson }}
conductor.elasticsearch.asyncWorkerQueueSize: {{ $v.elasticsearch.asyncWorkerQueueSize | toJson }}
conductor.elasticsearch.asyncMaxPoolSize: {{ $v.elasticsearch.asyncMaxPoolSize | toJson }}
conductor.elasticsearch.asyncBufferFlushTimeout: {{ $v.elasticsearch.asyncBufferFlushTimeout | toJson }}
{{- if eq $v.indexing.type "elasticsearch" }}
conductor.elasticsearch.version: {{ $v.elasticsearch.version | toJson }}
{{- end }}
conductor.elasticsearch.clusterHealthColor: {{ $v.elasticsearch.clusterHealthColor | toJson }}
conductor.elasticsearch.restClientConnectionRequestTimeout: {{ $v.elasticsearch.restClientConnectionRequestTimeout | toJson }}
{{- end }}
{{- if and $v.indexing.enabled (has $v.indexing.type (list "opensearch2" "opensearch3")) }}
conductor.opensearch.url: {{ $v.openSearch.url | toJson }}
conductor.opensearch.username: {{ $v.openSearch.username | toJson }}
conductor.opensearch.password: {{ include "conductor-oss-conductor.credential" (set $credential "key" "open-search-password") | toJson }}
conductor.opensearch.indexPrefix: {{ $v.openSearch.indexPrefix | toJson }}
conductor.opensearch.indexShardCount: {{ $v.openSearch.indexShardCount | toJson }}
conductor.opensearch.indexReplicasCount: {{ $v.openSearch.indexReplicasCount | toJson }}
conductor.opensearch.autoIndexManagementEnabled: {{ $v.openSearch.autoIndexManagementEnabled | toJson }}
conductor.opensearch.clusterHealthColor: {{ $v.openSearch.clusterHealthColor | toJson }}
conductor.opensearch.indexBatchSize: {{ $v.openSearch.indexBatchSize | toJson }}
conductor.opensearch.asyncWorkerQueueSize: {{ $v.openSearch.asyncWorkerQueueSize | toJson }}
conductor.opensearch.asyncMaxPoolSize: {{ $v.openSearch.asyncMaxPoolSize | toJson }}
conductor.opensearch.asyncBufferFlushTimeout: {{ $v.openSearch.asyncBufferFlushTimeout | toJson }}
conductor.opensearch.taskLogResultLimit: {{ $v.openSearch.taskLogResultLimit | toJson }}
conductor.opensearch.restClientConnectionRequestTimeout: {{ $v.openSearch.restClientConnectionRequestTimeout | toJson }}
{{- end }}
{{- if eq $v.indexing.type "postgres" }}
conductor.elasticsearch.version: 0
{{- end }}
{{- /* External payload storage (postgres is above) */}}
{{- if eq $v.externalPayloadStorage.type "s3" }}
conductor.external-payload-storage.type: s3
conductor.external-payload-storage.s3.bucketName: {{ $v.s3.externalPayloadStorage.bucketName | toJson }}
conductor.external-payload-storage.s3.signedUrlExpirationDuration: {{ $v.s3.externalPayloadStorage.signedUrlExpirationDuration | toJson }}
conductor.external-payload-storage.s3.region: {{ $v.s3.externalPayloadStorage.region | toJson }}
{{- end }}
{{- if eq (include "conductor-oss-conductor.usesAzureBlob" .) "true" }}
{{- $azureBlob := $v.azureBlob.externalPayloadStorage }}
conductor.external-payload-storage.type: azureblob
conductor.external-payload-storage.azureblob.connectionString: {{ include "conductor-oss-conductor.credential" (set $credential "key" "azure-blob-connection-string") | toJson }}
conductor.external-payload-storage.azureblob.endpoint: {{ $azureBlob.endpoint | toJson }}
conductor.external-payload-storage.azureblob.sasToken: {{ include "conductor-oss-conductor.credential" (set $credential "key" "azure-blob-sas-token") | toJson }}
conductor.external-payload-storage.azureblob.containerName: {{ $azureBlob.containerName | toJson }}
conductor.external-payload-storage.azureblob.signedUrlExpirationDuration: {{ $azureBlob.signedUrlExpirationSeconds | toJson }}
conductor.external-payload-storage.azureblob.workflowInputPath: {{ $azureBlob.workflowInputPath | toJson }}
conductor.external-payload-storage.azureblob.workflowOutputPath: {{ $azureBlob.workflowOutputPath | toJson }}
conductor.external-payload-storage.azureblob.taskInputPath: {{ $azureBlob.taskInputPath | toJson }}
conductor.external-payload-storage.azureblob.taskOutputPath: {{ $azureBlob.taskOutputPath | toJson }}
{{- end }}
{{- /* Event queues */}}
{{- $eventQueues := include "conductor-oss-conductor.eventQueues" . | fromYamlArray }}
{{- if has "amqp" $eventQueues }}
{{- $amqp := $v.amqpEventQueues }}
conductor.event-queues.amqp.enabled: true
conductor.event-queues.amqp.hosts: {{ $amqp.hosts | toJson }}
conductor.event-queues.amqp.username: {{ $amqp.username | toJson }}
conductor.event-queues.amqp.password: {{ include "conductor-oss-conductor.credential" (set $credential "key" "amqp-password") | toJson }}
conductor.event-queues.amqp.virtualHost: {{ $amqp.virtualHost | toJson }}
conductor.event-queues.amqp.port: {{ $amqp.port | toJson }}
conductor.event-queues.amqp.useNio: {{ $amqp.useNio | toJson }}
conductor.event-queues.amqp.batchSize: {{ $amqp.batchSize | toJson }}
conductor.event-queues.amqp.pollTimeDuration: {{ $amqp.pollTimeDuration | toJson }}
conductor.event-queues.amqp.queueType: {{ $amqp.queueType | toJson }}
conductor.event-queues.amqp.sequentialMsgProcessing: {{ $amqp.sequentialMsgProcessing | toJson }}
conductor.event-queues.amqp.connectionTimeoutInMilliSecs: {{ $amqp.connectionTimeoutInMilliSecs | toJson }}
conductor.event-queues.amqp.networkRecoveryIntervalInMilliSecs: {{ $amqp.networkRecoveryIntervalInMilliSecs | toJson }}
conductor.event-queues.amqp.requestHeartbeatTimeoutInSecs: {{ $amqp.requestHeartbeatTimeoutInSecs | toJson }}
conductor.event-queues.amqp.handshakeTimeoutInMilliSecs: {{ $amqp.handshakeTimeoutInMilliSecs | toJson }}
conductor.event-queues.amqp.maxChannelCount: {{ $amqp.maxChannelCount | toJson }}
conductor.event-queues.amqp.limit: {{ $amqp.limit | toJson }}
conductor.event-queues.amqp.duration: {{ $amqp.duration | toJson }}
{{- /* The retry type binds as "type" (setter setType) */}}
conductor.event-queues.amqp.type: {{ $amqp.retryType | toJson }}
conductor.event-queues.amqp.useExchange: {{ $amqp.useExchange | toJson }}
conductor.event-queues.amqp.listenerQueuePrefix: {{ $amqp.listenerQueuePrefix | toJson }}
conductor.event-queues.amqp.durable: {{ $amqp.durable | toJson }}
conductor.event-queues.amqp.exclusive: {{ $amqp.exclusive | toJson }}
{{- end }}
{{- if has "nats_stream" $eventQueues }}
{{- $nats := $v.natsEventQueues.natsStream }}
conductor.event-queues.nats-stream.enabled: true
conductor.event-queues.nats-stream.clusterId: {{ $nats.clusterID | toJson }}
conductor.event-queues.nats-stream.durableName: {{ $nats.durableName | toJson }}
conductor.event-queues.nats-stream.url: {{ $nats.url | toJson }}
conductor.event-queues.nats-stream.listenerQueuePrefix: {{ $nats.listenerQueuePrefix | toJson }}
{{- end }}
{{- if has "jsm" $eventQueues }}
{{- $jsm := $v.natsEventQueues.jetStream }}
conductor.event-queues.jsm.enabled: true
conductor.event-queues.jsm.url: {{ $jsm.url | toJson }}
conductor.event-queues.jsm.durableName: {{ $jsm.durableName | toJson }}
conductor.event-queues.jsm.streamStorageType: {{ $jsm.streamStorageType | toJson }}
conductor.event-queues.jsm.replicas: {{ $jsm.replicas | toJson }}
conductor.event-queues.jsm.listenerQueuePrefix: {{ $jsm.listenerQueuePrefix | toJson }}
{{- end }}
{{- if has "kafka" $eventQueues }}
{{- $kafka := $v.kafkaEventQueues }}
conductor.event-queues.kafka.enabled: true
conductor.event-queues.kafka.bootstrap-servers: {{ $kafka.bootstrapServers | toJson }}
conductor.event-queues.kafka.dlq-topic: {{ $kafka.dlqTopic | toJson }}
conductor.event-queues.kafka.listener-queue-prefix: {{ $kafka.listenerQueuePrefix | toJson }}
conductor.event-queues.kafka.poll-time-duration: {{ $kafka.pollTimeDuration | toJson }}
{{- range $client := list "consumer" "producer" "admin" }}
{{- range $name, $value := (get $kafka $client) }}
{{ printf "conductor.event-queues.kafka.%s.%s" $client $name }}: {{ $value | toJson }}
{{- end }}
{{- end }}
{{- end }}
{{- /* Status listeners and notifier */}}
{{- $workflowListeners := compact (list $v.statusListener.workflowType (ternary "archive" "" (eq (toString $v.workflowArchival.enabled) "true"))) }}
{{- if gt (len $workflowListeners) 1 }}
conductor.workflow-status-listener.type: composite
conductor.workflow-status-listener.composite.types: {{ join "," $workflowListeners | toJson }}
{{- else }}
conductor.workflow-status-listener.type: {{ join "" $workflowListeners | toJson }}
{{- end }}
{{- if $v.workflowArchival.enabled }}
{{- $archival := $v.workflowArchival }}
conductor.workflow-status-listener.archival.workflowArchivalType: {{ $archival.type | toJson }}
conductor.workflow-status-listener.archival.ttlDuration: {{ $archival.ttl | toJson }}
conductor.workflow-status-listener.archival.delaySeconds: {{ $archival.delaySeconds | toJson }}
conductor.workflow-status-listener.archival.workflowArchiveUnsuccessfulOnly: {{ $archival.unsuccessfulOnly | toJson }}
conductor.workflow-status-listener.archival.delayQueueWorkerThreadCount: {{ $archival.delayQueueWorkerThreadCount | toJson }}
conductor.workflow-status-listener.archival.workflowS3ArchivalDefaultBucketName: {{ $archival.s3BucketName | toJson }}
conductor.workflow-status-listener.archival.workflowS3ArchivalBucketRegion: {{ $archival.s3BucketRegion | toJson }}
{{- end }}
conductor.task-status-listener.type: {{ $v.statusListener.taskType | toJson }}
{{- if $v.statusNotifier.url }}
{{- $notifier := $v.statusNotifier }}
conductor.status-notifier.notification.url: {{ $notifier.url | toJson }}
conductor.status-notifier.notification.endpointWorkflow: {{ $notifier.endpointWorkflow | toJson }}
conductor.status-notifier.notification.endpointTask: {{ $notifier.endpointTask | toJson }}
conductor.status-notifier.notification.subscribedTaskStatuses: {{ $notifier.subscribedTaskStatuses | toJson }}
conductor.status-notifier.notification.subscribedWorkflowStatuses: {{ $notifier.subscribedWorkflowStatuses | toJson }}
conductor.status-notifier.notification.headerPrefer: {{ $notifier.headerPrefer | toJson }}
conductor.status-notifier.notification.headerPreferValue: {{ $notifier.headerPreferValue | toJson }}
conductor.status-notifier.notification.requestTimeoutMsConnect: {{ $notifier.requestTimeoutMsConnect | toJson }}
conductor.status-notifier.notification.requestTimeoutMsRead: {{ $notifier.requestTimeoutMsRead | toJson }}
conductor.status-notifier.notification.requestTimeoutMsConnMgr: {{ $notifier.requestTimeoutMsConnMgr | toJson }}
conductor.status-notifier.notification.requestRetryCount: {{ $notifier.requestRetryCount | toJson }}
conductor.status-notifier.notification.requestRetryCountIntervalMs: {{ $notifier.requestRetryIntervalMs | toJson }}
conductor.status-notifier.notification.connectionPoolMaxRequest: {{ $notifier.connectionPoolMaxRequest | toJson }}
conductor.status-notifier.notification.connectionPoolMaxRequestPerRoute: {{ $notifier.connectionPoolMaxRequestPerRoute | toJson }}
{{- end }}
{{- /* AI */}}
conductor.integrations.ai.enabled: {{ $v.ai.enabled | toJson }}
{{- if not $v.ai.enabled }}
{{- /* The AI model providers are initialized (and log errors for the missing API keys) even when AI is disabled */}}
logging.level.org.conductoross.conductor.ai.AIModelProvider: "OFF"
{{- end }}
{{- if $v.ai.enabled }}
{{- /* The API keys (but Bedrock's) come from the environment variables read by Conductor's application.properties */}}
{{- /* The default (the user's home directory) is in the read-only root filesystem */}}
conductor.file-storage.parentDir: /tmp/worker-payload/
conductor.ai.outbound.allowed-origins: {{ $v.ai.outbound.allowedOrigins | toJson }}
conductor.ai.outbound.allow-private-networks: {{ $v.ai.outbound.allowPrivateNetworks | toJson }}
conductor.ai.decision.provider: {{ $v.ai.decision.provider | toJson }}
conductor.ai.decision.api-shape: {{ $v.ai.decision.apiShape | toJson }}
conductor.ai.openai.organization-id: {{ $v.ai.openAI.organizationID | toJson }}
conductor.ai.azureopenai.base-url: {{ $v.ai.azureOpenAI.baseUrl | toJson }}
conductor.ai.azureopenai.deployment-name: {{ $v.ai.azureOpenAI.deploymentName | toJson }}
conductor.ai.bedrock.access-key: {{ include "conductor-oss-conductor.credential" (set $credential "key" "ai-bedrock-access-key") | toJson }}
conductor.ai.bedrock.secret-key: {{ include "conductor-oss-conductor.credential" (set $credential "key" "ai-bedrock-secret-key") | toJson }}
conductor.ai.bedrock.bearerToken: {{ include "conductor-oss-conductor.credential" (set $credential "key" "ai-bedrock-bearer-token") | toJson }}
conductor.ai.bedrock.region: {{ $v.ai.bedrock.region | toJson }}
conductor.ai.gemini.project-id: {{ $v.ai.gemini.projectID | toJson }}
conductor.ai.gemini.location: {{ $v.ai.gemini.location | toJson }}
conductor.ai.ollama.base-url: {{ $v.ai.ollama.baseUrl | toJson }}
{{- end }}
conductor.document-access-policy.disabled: {{ $v.documentAccessPolicy.disabled | toJson }}
conductor.document-access-policy.allowed-directories: {{ $v.documentAccessPolicy.allowedDirectories | toJson }}
conductor.document-access-policy.blocked-path-prefixes: {{ $v.documentAccessPolicy.blockedPathPrefixes | toJson }}
conductor.document-access-policy.blocked-file-names: {{ $v.documentAccessPolicy.blockedFileNames | toJson }}
conductor.document-access-policy.blocked-hosts: {{ $v.documentAccessPolicy.blockedHosts | toJson }}
{{- /* Metrics and management */}}
{{- $export := $v.management.metricsExport }}
conductor.metrics-logger.enabled: {{ $v.metrics.loggerEnabled | toJson }}
management.endpoints.web.exposure.include: {{ $v.management.endpointsWebExposureInclude | toJson }}
management.metrics.distribution.percentiles.http.server.requests: {{ $v.management.metricsPercentiles | toJson }}
management.endpoint.health.show-details: {{ $v.management.healthShowDetails | toJson }}
management.health.redis.enabled: {{ $v.management.healthRedisEnabled | toJson }}
management.health.elasticsearch.enabled: {{ $v.management.healthElasticsearchEnabled | toJson }}
management.atlas.metrics.export.enabled: {{ $export.atlas | toJson }}
management.otlp.metrics.export.enabled: {{ $export.otlp | toJson }}
management.influx.metrics.export.enabled: {{ $export.influx | toJson }}
management.elastic.metrics.export.enabled: {{ $export.elastic | toJson }}
management.dynatrace.metrics.export.enabled: {{ $export.dynatrace | toJson }}
management.newrelic.metrics.export.enabled: {{ $export.newRelic | toJson }}
management.stackdriver.metrics.export.enabled: {{ $export.stackdriver | toJson }}
management.stackdriver.metrics.export.project-id: {{ $export.stackdriverProjectID | toJson }}
management.datadog.metrics.export.enabled: {{ $export.datadog | toJson }}
management.datadog.metrics.export.api-key: {{ include "conductor-oss-conductor.credential" (set $credential "key" "datadog-api-key") | toJson }}
management.statsd.metrics.export.enabled: {{ $export.statsD | toJson }}
management.cloudwatch.metrics.export.enabled: {{ $export.cloudWatch | toJson }}
management.cloudwatch.metrics.export.namespace: {{ $export.cloudWatchNamespace | toJson }}
management.azuremonitor.metrics.export.enabled: {{ $export.azureMonitor | toJson }}
management.azuremonitor.metrics.export.instrumentation-key: {{ include "conductor-oss-conductor.credential" (set $credential "key" "azure-monitor-instrumentation-key") | toJson }}
management.jmx.metrics.export.enabled: {{ $export.jmx | toJson }}
{{- /* gRPC */}}
conductor.grpc-server.enabled: {{ $v.grpcServer.enabled | toJson }}
conductor.grpc-server.port: {{ $v.container.ports.grpc | toJson }}
{{- end -}}
