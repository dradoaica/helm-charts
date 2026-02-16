# conductor-oss-conductor

![Version: 3.22.0](https://img.shields.io/badge/Version-3.22.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.22.0-rc1](https://img.shields.io/badge/AppVersion-3.22.0--rc1-informational?style=flat-square)

Conductor OSS Conductor is a platform originally created at Netflix to orchestrate workflows that span across microservices. This chart deploys Conductor OSS Conductor as a Deployment.

**Homepage:** <https://docs.conductor-oss.org/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| dradoaica | <dradoaica@gmail.com> | <https://dradoaica.blogspot.com/> |

## Source Code

* <https://github.com/conductor-oss/conductor>

## Requirements

Kubernetes: `>= 1.26.0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Node affinity |
| ai | object | `{"anthropic":{"apiKey":""},"azureopenai":{"apiKey":"","baseUrl":"","deploymentName":""},"bedrock":{"accessKey":"","region":"us-east-1","secretKey":""},"cohere":{"apiKey":""},"enabled":true,"gemini":{"location":"us-central1","projectId":""},"grok":{"apiKey":""},"huggingface":{"apiKey":""},"mistral":{"apiKey":""},"ollama":{"baseUrl":"http://localhost:11434"},"openai":{"apiKey":"","organizationId":""},"perplexity":{"apiKey":""},"stabilityai":{"apiKey":""}}` | AI configuration |
| ai.anthropic | object | `{"apiKey":""}` | Anthropic configuration |
| ai.anthropic.apiKey | string | `""` | Anthropic API Key |
| ai.azureopenai | object | `{"apiKey":"","baseUrl":"","deploymentName":""}` | Azure OpenAI configuration |
| ai.azureopenai.apiKey | string | `""` | Azure OpenAI API Key |
| ai.azureopenai.baseUrl | string | `""` | Azure OpenAI Base URL |
| ai.azureopenai.deploymentName | string | `""` | Azure OpenAI Deployment Name |
| ai.bedrock | object | `{"accessKey":"","region":"us-east-1","secretKey":""}` | AWS Bedrock configuration |
| ai.bedrock.accessKey | string | `""` | AWS Access Key ID |
| ai.bedrock.region | string | `"us-east-1"` | AWS Region |
| ai.bedrock.secretKey | string | `""` | AWS Secret Access Key |
| ai.cohere | object | `{"apiKey":""}` | Cohere configuration |
| ai.cohere.apiKey | string | `""` | Cohere API Key |
| ai.gemini | object | `{"location":"us-central1","projectId":""}` | Google Gemini configuration |
| ai.gemini.location | string | `"us-central1"` | Google Cloud Location |
| ai.gemini.projectId | string | `""` | Google Cloud Project ID |
| ai.grok | object | `{"apiKey":""}` | Grok configuration |
| ai.grok.apiKey | string | `""` | Grok API Key |
| ai.huggingface | object | `{"apiKey":""}` | HuggingFace configuration |
| ai.huggingface.apiKey | string | `""` | HuggingFace API Key |
| ai.mistral | object | `{"apiKey":""}` | Mistral configuration |
| ai.mistral.apiKey | string | `""` | Mistral API Key |
| ai.ollama | object | `{"baseUrl":"http://localhost:11434"}` | Ollama configuration |
| ai.ollama.baseUrl | string | `"http://localhost:11434"` | Ollama Base URL |
| ai.openai | object | `{"apiKey":"","organizationId":""}` | OpenAI configuration |
| ai.openai.apiKey | string | `""` | OpenAI API Key |
| ai.openai.organizationId | string | `""` | OpenAI Organization ID |
| ai.perplexity | object | `{"apiKey":""}` | Perplexity configuration |
| ai.perplexity.apiKey | string | `""` | Perplexity API Key |
| ai.stabilityai | object | `{"apiKey":""}` | StabilityAI configuration |
| ai.stabilityai.apiKey | string | `""` | StabilityAI API Key |
| amqpEventQueues | object | `{"batchSize":1,"connectionTimeoutInMilliSecs":180000,"durable":false,"duration":1000,"enabled":false,"exclusive":false,"handshakeTimeoutInMilliSecs":180000,"hosts":"","limit":50,"listenerQueuePrefix":"","maxChannelCount":5000,"maxPriority":-1,"networkRecoveryIntervalInMilliSecs":5000,"password":"","pollTimeDuration":"100ms","port":5672,"queueType":"classic","requestHeartbeatTimeoutInSecs":30,"retryType":"REGULARINTERVALS","sequentialMsgProcessing":true,"useExchange":true,"useNio":false,"username":"","virtualHost":"/"}` | AMQP (RabbitMQ) Event Queues configuration |
| amqpEventQueues.batchSize | int | `1` | Batch size for message consumption |
| amqpEventQueues.connectionTimeoutInMilliSecs | int | `180000` | Connection timeout in ms |
| amqpEventQueues.durable | bool | `false` | Whether queues are durable |
| amqpEventQueues.duration | int | `1000` | Rate limit duration in ms |
| amqpEventQueues.enabled | bool | `false` | Enable AMQP event queue support |
| amqpEventQueues.exclusive | bool | `false` | Whether queues are exclusive |
| amqpEventQueues.handshakeTimeoutInMilliSecs | int | `180000` | Handshake timeout in ms |
| amqpEventQueues.hosts | string | `""` | RabbitMQ server host(s) |
| amqpEventQueues.limit | int | `50` | Rate limit |
| amqpEventQueues.listenerQueuePrefix | string | `""` | Listener queue prefix |
| amqpEventQueues.maxChannelCount | int | `5000` | Maximum channel count |
| amqpEventQueues.maxPriority | int | `-1` | Max priority for messages (-1 to disable) |
| amqpEventQueues.networkRecoveryIntervalInMilliSecs | int | `5000` | Network recovery interval in ms |
| amqpEventQueues.password | string | `""` | RabbitMQ password |
| amqpEventQueues.pollTimeDuration | string | `"100ms"` | Poll time duration (e.g., 100ms) |
| amqpEventQueues.port | int | `5672` | RabbitMQ port |
| amqpEventQueues.queueType | string | `"classic"` | Queue type (classic, quorum) |
| amqpEventQueues.requestHeartbeatTimeoutInSecs | int | `30` | Heartbeat timeout in seconds |
| amqpEventQueues.retryType | string | `"REGULARINTERVALS"` | Retry type (REGULARINTERVALS, EXPONENTIALBACKOFF) |
| amqpEventQueues.sequentialMsgProcessing | bool | `true` | Whether to process messages sequentially |
| amqpEventQueues.useExchange | bool | `true` | Whether to use exchange (true) or queue (false) |
| amqpEventQueues.useNio | bool | `false` | Whether to use NIO |
| amqpEventQueues.username | string | `""` | RabbitMQ username |
| amqpEventQueues.virtualHost | string | `"/"` | RabbitMQ virtual host |
| annotations | object | `{}` | Annotations to add to all resources |
| app | object | `{"activeWorkerLastPollTimeout":"","appId":"","asyncIndexingEnabled":"","asyncUpdateDelay":"","asyncUpdateShortRunningWorkflowDuration":"10m","enableRemoveRedisKey":false,"eventExecutionIndexingEnabled":"","eventMessageIndexingEnabled":"","eventProcessorThreadCount":"","eventQueueLongPollTimeout":"","eventQueuePollCount":"","eventQueuePollInterval":"","eventQueueSchedulerPollThreadCount":"","executorServiceMaxThreadCount":"","isolatedSystemTaskWorkerThreadCount":"","lockLeaseTime":"","lockTimeToTry":500,"maxPostponeDurationSeconds":"","maxTaskInputPayloadSizeThreshold":"4GB","maxTaskOutputPayloadSizeThreshold":"4GB","maxWorkflowInputPayloadSizeThreshold":"4GB","maxWorkflowOutputPayloadSizeThreshold":"4GB","maxWorkflowVariablesPayloadSizeThreshold":"100MB","ownerEmailMandatory":"","stack":"","summaryInputOutputJsonSerializationEnabled":"","sweeperThreadCount":"","sweeperWorkflowPollTimeout":"","systemTaskMaxPollCount":20,"systemTaskWorkerCallbackDuration":"","systemTaskWorkerExecutionNamespace":"","systemTaskWorkerPollInterval":"","systemTaskWorkerThreadCount":20,"taskExecLogIndexingEnabled":"","taskExecLogSizeLimit":"","taskExecutionPostponeDuration":"","taskIndexingEnabled":"","taskInputPayloadSizeThreshold":"1MB","taskOutputPayloadSizeThreshold":"1MB","ttlRedisKeyExpire":"","workflowExecutionLockEnabled":true,"workflowInputPayloadSizeThreshold":"1MB","workflowNameValidationEnabled":false,"workflowOffsetTimeout":"","workflowOutputPayloadSizeThreshold":"1MB","workflowRepairServiceEnabled":false}` | App configuration |
| app.activeWorkerLastPollTimeout | string | `""` | The time to consider if a worker is actively polling for a task (e.g., 10s) |
| app.appId | string | `""` | The ID with which the app has been registered (e.g., conductor, myApp) |
| app.asyncIndexingEnabled | string | `""` | Whether to enable asynchronous indexing to Elasticsearch |
| app.asyncUpdateDelay | string | `""` | The delay with which short-running workflows will be updated in Elasticsearch when async indexing is enabled (e.g., 60s) |
| app.asyncUpdateShortRunningWorkflowDuration | string | `"10m"` | The duration of workflow execution qualifying as short-running when async indexing to Elasticsearch is enabled (e.g., 30s) |
| app.enableRemoveRedisKey | bool | `false` | Whether to enable the remove Redis key feature |
| app.eventExecutionIndexingEnabled | string | `""` | Whether to enable indexing of event execution results |
| app.eventMessageIndexingEnabled | string | `""` | Whether to enable indexing of messages within event payloads |
| app.eventProcessorThreadCount | string | `""` | The number of threads to configure the threadpool in the event processor |
| app.eventQueueLongPollTimeout | string | `""` | The timeout for the poll operation on the default event queue (e.g., 1000ms) |
| app.eventQueuePollCount | string | `""` | The number of messages to be polled from a default event queue in a single operation |
| app.eventQueuePollInterval | string | `""` | The time interval at which the default event queues will be polled (e.g., 100ms) |
| app.eventQueueSchedulerPollThreadCount | string | `""` | The number of threads used in the Scheduler for polling events from multiple event queues |
| app.executorServiceMaxThreadCount | string | `""` | The maximum number of threads to be allocated to the executor service threadpool |
| app.isolatedSystemTaskWorkerThreadCount | string | `""` | The number of threads to be used within the threadpool for system task workers in each isolation group |
| app.lockLeaseTime | string | `""` | The time for which the lock is leased (e.g., 60000ms, 1m) |
| app.lockTimeToTry | int | `500` | The time for which the thread will block in an attempt to acquire the lock (e.g., 500ms, 1s) |
| app.maxPostponeDurationSeconds | string | `""` | The maximum timeout duration to set when a workflow with a running task is pushed to the decider queue (e.g., 30m, 1h) |
| app.maxTaskInputPayloadSizeThreshold | string | `"4GB"` | The maximum threshold of the task input payload size beyond which the task input will be rejected and the task marked as FAILED_WITH_TERMINAL_ERROR |
| app.maxTaskOutputPayloadSizeThreshold | string | `"4GB"` | The maximum threshold of the task output payload size beyond which the task output will be rejected and the task marked as FAILED_WITH_TERMINAL_ERROR |
| app.maxWorkflowInputPayloadSizeThreshold | string | `"4GB"` | The maximum threshold of the workflow input payload size beyond which input will be rejected and the workflow marked as FAILED |
| app.maxWorkflowOutputPayloadSizeThreshold | string | `"4GB"` | The maximum threshold of the workflow output payload size beyond which output will be rejected and the workflow marked as FAILED |
| app.maxWorkflowVariablesPayloadSizeThreshold | string | `"100MB"` | The maximum threshold of the workflow variables payload size beyond which the task changes will be rejected and the task marked as FAILED_WITH_TERMINAL_ERROR |
| app.ownerEmailMandatory | string | `""` | Whether to validate the owner email field as mandatory within workflow and task definitions |
| app.stack | string | `""` | Name of the stack within which the app is running (e.g., dev, testing, staging, prod) |
| app.summaryInputOutputJsonSerializationEnabled | string | `""` | Whether to enable summary input/output JSON serialization |
| app.sweeperThreadCount | string | `""` | The number of threads to use for background sweeping on active workflows |
| app.sweeperWorkflowPollTimeout | string | `""` | The timeout for polling workflows to be swept (e.g., 2000ms, 2s) |
| app.systemTaskMaxPollCount | int | `20` | The maximum number of threads to be polled within the threadpool for system task workers |
| app.systemTaskWorkerCallbackDuration | string | `""` | The interval after which a system task will be checked by the system task worker for completion (e.g., 30s) |
| app.systemTaskWorkerExecutionNamespace | string | `""` | The namespace for the system task workers to provide instance-level isolation |
| app.systemTaskWorkerPollInterval | string | `""` | The interval at which system task queues will be polled by system task workers (e.g., 50ms) |
| app.systemTaskWorkerThreadCount | int | `20` | The number of threads in the threadpool for system task workers |
| app.taskExecLogIndexingEnabled | string | `""` | Whether to enable indexing of task execution logs |
| app.taskExecLogSizeLimit | string | `""` | The maximum size of task execution logs |
| app.taskExecutionPostponeDuration | string | `""` | The time for which a task execution will be postponed if rate-limited or concurrent execution limited (e.g., 60s) |
| app.taskIndexingEnabled | string | `""` | Whether to enable indexing of tasks |
| app.taskInputPayloadSizeThreshold | string | `"1MB"` | The threshold of the task input payload size beyond which the payload will be stored in ExternalPayloadStorage |
| app.taskOutputPayloadSizeThreshold | string | `"1MB"` | The threshold of the task output payload size beyond which the payload will be stored in ExternalPayloadStorage |
| app.ttlRedisKeyExpire | string | `""` | TTL for Redis key expiration |
| app.workflowExecutionLockEnabled | bool | `true` | Whether to enable the workflow execution lock |
| app.workflowInputPayloadSizeThreshold | string | `"1MB"` | The threshold of the workflow input payload size beyond which the payload will be stored in ExternalPayloadStorage |
| app.workflowNameValidationEnabled | bool | `false` | Whether to enable workflow/task definition name validation |
| app.workflowOffsetTimeout | string | `""` | The timeout duration to set when a workflow is pushed to the decider queue (e.g., 30s, 1m) |
| app.workflowOutputPayloadSizeThreshold | string | `"1MB"` | The threshold of the workflow output payload size beyond which the payload will be stored in ExternalPayloadStorage |
| app.workflowRepairServiceEnabled | bool | `false` | Whether to enable the workflow repair service |
| autoscaling.create | bool | `false` | Create a HorizontalPodAutoscaler |
| autoscaling.maxReplicas | int | `10` | Maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage |
| autoscaling.targetMemoryUtilizationPercentage | int | `80` | Target memory utilization percentage |
| container.ports | object | `{"grpc":8090,"rest":8080,"ui":5000}` | Container ports used by the Pod spec and as Service targetPort values |
| containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}}` | Container security context configuration |
| containerSecurityContext.enabled | bool | `true` | Enable container security context |
| cors | object | `{"allowedOrigins":"*"}` | CORS configuration |
| cors.allowedOrigins | string | `"*"` | Allowed origins for CORS (comma-separated, or * for all) |
| db | object | `{"type":"redis_standalone"}` | DB configuration |
| db.type | string | `"redis_standalone"` | DB type (redis_standalone, redis_cluster, redis_sentinel, mysql, postgres, memory) |
| defaultEventQueue | object | `{"type":"amqp"}` | Default event queue configuration |
| defaultEventQueue.type | string | `"amqp"` | The default event queue type (e.g., amqp, nats_stream, kafka) |
| elasticsearch | object | `{"clusterHealthColor":"yellow","indexName":"","indexPrefix":"","indexReplicasCount":0,"password":"","restClientConnectionTimeout":5000,"restClientReadTimeout":30000,"url":"","username":"","version":7}` | Elasticsearch configuration |
| elasticsearch.clusterHealthColor | string | `"yellow"` | Elasticsearch cluster health color |
| elasticsearch.indexName | string | `""` | Elasticsearch index name |
| elasticsearch.indexPrefix | string | `""` | Elasticsearch index prefix |
| elasticsearch.indexReplicasCount | int | `0` | Elasticsearch index replicas count |
| elasticsearch.password | string | `""` | Elasticsearch password |
| elasticsearch.restClientConnectionTimeout | int | `5000` | Elasticsearch REST client connection timeout |
| elasticsearch.restClientReadTimeout | int | `30000` | Elasticsearch REST client read timeout |
| elasticsearch.url | string | `""` | Elasticsearch URL |
| elasticsearch.username | string | `""` | Elasticsearch username |
| elasticsearch.version | int | `7` | Elasticsearch version |
| env | object | `{"EXTRA_JVM_OPTS":""}` | Environment variables |
| externalPayloadStorage | object | `{"type":null}` | External payload storage configuration |
| externalPayloadStorage.type | string | `nil` | External payload storage type (postgres, null) |
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
| grpcServer | object | `{"enabled":true,"port":8090}` | GRPC Server configuration |
| grpcServer.enabled | bool | `true` | Enable GRPC server |
| grpcServer.port | int | `8090` | GRPC server port |
| image.pullPolicy | string | `"IfNotPresent"` | Main container image pull policy |
| image.registry | string | `"docker.io"` | Main container image registry |
| image.repository | string | `"conductoross/conductor"` | Main container image repository |
| image.tag | string | `""` | Main container image tag |
| indexing | object | `{"enabled":true,"type":"elasticsearch"}` | Indexing configuration |
| indexing.enabled | bool | `true` | Enable indexing |
| indexing.type | string | `"elasticsearch"` | Indexing type (elasticsearch, opensearch, postgres, memory) |
| ingress.annotations | object | `{}` | Additional annotations for the Ingress |
| ingress.className | string | `""` | IngressClass that will be used to implement the Ingress |
| ingress.create | bool | `false` | Create an Ingress for external HTTP access |
| ingress.hosts | list | `[{"host":"conductor-api.local","paths":[{"path":"/","pathType":"Prefix","port":8080}]},{"host":"conductor-ui.local","paths":[{"path":"/","pathType":"Prefix","port":5000}]}]` | List of Ingress hosts with paths for API and UI |
| ingress.tls | list | `[]` | TLS configuration for Ingress |
| kafkaEventQueues | object | `{"admin":{},"bootstrapServers":"kafka:29092","consumer":{},"dlqTopic":"conductor-dlq","enabled":false,"listenerQueuePrefix":"conductor_","pollTimeDuration":"500ms","producer":{}}` | Kafka Event Queues configuration |
| kafkaEventQueues.admin | object | `{}` | Kafka admin client properties |
| kafkaEventQueues.bootstrapServers | string | `"kafka:29092"` | Kafka bootstrap servers |
| kafkaEventQueues.consumer | object | `{}` | Kafka consumer client properties |
| kafkaEventQueues.dlqTopic | string | `"conductor-dlq"` | Dead letter queue topic |
| kafkaEventQueues.enabled | bool | `false` | Enable Kafka event queue support |
| kafkaEventQueues.listenerQueuePrefix | string | `"conductor_"` | Listener queue prefix |
| kafkaEventQueues.pollTimeDuration | string | `"500ms"` | Poll time duration (e.g., 500ms) |
| kafkaEventQueues.producer | object | `{}` | Kafka producer client properties |
| labels | object | `{}` | Additional labels to add to all resources |
| lifecycleHooks | object | `{}` | Lifecycle hooks configuration |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/health","port":8080},"initialDelaySeconds":5,"periodSeconds":30,"successThreshold":1,"timeoutSeconds":10}` | Liveness probe configuration |
| livenessProbe.enabled | bool | `true` | Enable liveness probe |
| logging | object | `{"level":{"root":"INFO"}}` | Logging configuration |
| logging.level.root | string | `"INFO"` | Root log level |
| management | object | `{"endpointsWebExposureInclude":"health,info,metrics,prometheus","healthRedisEnabled":true,"healthShowDetails":"always","metricsExport":{"atlas":false,"azureMonitor":false,"azureMonitorInstrumentationKey":"","cloudwatch":false,"cloudwatchNamespace":"conductor","datadog":false,"datadogApiKey":"","dynatrace":false,"elastic":false,"influx":false,"jmx":false,"newRelic":false,"otlp":false,"stackdriver":false,"stackdriverProjectId":"","statsd":false},"metricsPercentiles":"0.50,0.75,0.90,0.95,0.99"}` | Management configuration |
| management.endpointsWebExposureInclude | string | `"health,info,metrics,prometheus"` | Actuator endpoints to expose (comma-separated) |
| management.healthRedisEnabled | bool | `true` | Enable Redis health check |
| management.healthShowDetails | string | `"always"` | Health endpoint detail level (never, when_authorized, always) |
| management.metricsExport | object | `{"atlas":false,"azureMonitor":false,"azureMonitorInstrumentationKey":"","cloudwatch":false,"cloudwatchNamespace":"conductor","datadog":false,"datadogApiKey":"","dynatrace":false,"elastic":false,"influx":false,"jmx":false,"newRelic":false,"otlp":false,"stackdriver":false,"stackdriverProjectId":"","statsd":false}` | Metrics export backends |
| management.metricsExport.atlas | bool | `false` | Enable Atlas metrics export |
| management.metricsExport.azureMonitor | bool | `false` | Enable Azure Monitor metrics export |
| management.metricsExport.azureMonitorInstrumentationKey | string | `""` | Azure Monitor Instrumentation Key |
| management.metricsExport.cloudwatch | bool | `false` | Enable CloudWatch metrics export |
| management.metricsExport.cloudwatchNamespace | string | `"conductor"` | CloudWatch Namespace |
| management.metricsExport.datadog | bool | `false` | Enable Datadog metrics export |
| management.metricsExport.datadogApiKey | string | `""` | Datadog API Key |
| management.metricsExport.dynatrace | bool | `false` | Enable Dynatrace metrics export |
| management.metricsExport.elastic | bool | `false` | Enable Elastic metrics export |
| management.metricsExport.influx | bool | `false` | Enable Influx metrics export |
| management.metricsExport.jmx | bool | `false` | Enable JMX metrics export |
| management.metricsExport.newRelic | bool | `false` | Enable New Relic metrics export |
| management.metricsExport.otlp | bool | `false` | Enable OTLP metrics export |
| management.metricsExport.stackdriver | bool | `false` | Enable Stackdriver metrics export |
| management.metricsExport.stackdriverProjectId | string | `""` | Stackdriver Project ID |
| management.metricsExport.statsd | bool | `false` | Enable StatsD metrics export |
| management.metricsPercentiles | string | `"0.50,0.75,0.90,0.95,0.99"` | Request metrics percentiles (comma-separated) |
| memory.g1HeapRegionSizeMb | string | `""` | JVM G1 Heap region size in MB. If not set, defaults to 1 |
| memory.maxDirectMemorySizeMb | string | `""` | JVM DirectMemory max size in MB. If not set, defaults to 256 |
| memory.maxMetaspaceSizeMb | string | `""` | JVM Metaspace max size in MB. If not set, defaults to 256 |
| memory.onHeapMb | string | `""` | On-heap memory limit in MB. If set, -Xms and -Xmx will be value. If not set, defaults to 2048 |
| memory.reservedCodeCacheSizeMb | string | `""` | JVM ReservedCodeCache size in MB. If not set, defaults to 240 |
| metrics | object | `{"loggerEnabled":false,"loggerReportPeriodSeconds":1,"prometheusEnabled":false}` | Metrics configuration |
| metrics.loggerEnabled | bool | `false` | Enable metrics logging |
| metrics.loggerReportPeriodSeconds | int | `1` | Metrics logging a report period in seconds |
| metrics.prometheusEnabled | bool | `false` | Enable Prometheus metrics |
| mysql | object | `{"database":"","host":"","password":"","port":3306,"username":""}` | MySQL configuration |
| mysql.database | string | `""` | MySQL database name |
| mysql.host | string | `""` | MySQL host |
| mysql.password | string | `""` | MySQL password |
| mysql.port | int | `3306` | MySQL port |
| mysql.username | string | `""` | MySQL username |
| nameOverride | string | `""` | String to partially override the fullname template with a string (will prepend the release name) |
| natsEventQueues | object | `{"enabled":false,"natsStream":{"clusterId":"test-cluster","durableName":"","listenerQueuePrefix":"","url":"nats://localhost:4222"}}` | NATS Event Queues configuration |
| natsEventQueues.enabled | bool | `false` | Enable NATS event queue support |
| natsEventQueues.natsStream.clusterId | string | `"test-cluster"` | NATS streaming cluster ID |
| natsEventQueues.natsStream.durableName | string | `""` | NATS streaming durable name |
| natsEventQueues.natsStream.listenerQueuePrefix | string | `""` | Listener queue prefix |
| natsEventQueues.natsStream.url | string | `"nats://localhost:4222"` | NATS streaming URL |
| networkPolicy.create | bool | `false` | Create a NetworkPolicy |
| networkPolicy.egress | list | `[{"ports":[{"port":53,"protocol":"UDP"},{"port":53,"protocol":"TCP"}],"to":[{"ipBlock":{"cidr":"0.0.0.0/0"}}]}]` | NetworkPolicy egress rules |
| networkPolicy.ingress | list | `[]` | NetworkPolicy ingress rules |
| networkPolicy.name | string | `""` | Name for the NetworkPolicy (defaults to fullname when empty) |
| nodeSelector | object | `{}` | Node selector |
| opensearch | object | `{"clusterHealthColor":"green","indexName":"","indexPrefix":"","indexReplicasCount":0,"password":"","restClientConnectionTimeout":5000,"restClientReadTimeout":30000,"url":"","username":"","version":0}` | OpenSearch configuration |
| opensearch.clusterHealthColor | string | `"green"` | OpenSearch cluster health color |
| opensearch.indexName | string | `""` | OpenSearch index name |
| opensearch.indexPrefix | string | `""` | OpenSearch index prefix |
| opensearch.indexReplicasCount | int | `0` | OpenSearch index replicas count |
| opensearch.password | string | `""` | OpenSearch password |
| opensearch.restClientConnectionTimeout | int | `5000` | OpenSearch REST client connection timeout |
| opensearch.restClientReadTimeout | int | `30000` | OpenSearch REST client read timeout |
| opensearch.url | string | `""` | OpenSearch URL |
| opensearch.username | string | `""` | OpenSearch username |
| opensearch.version | int | `0` | OpenSearch version |
| podAnnotations | object | `{}` | Additional annotations to add to pods |
| podDisruptionBudget.create | bool | `false` | Create a PodDisruptionBudget for high availability |
| podDisruptionBudget.maxUnavailable | string | `""` | Maximum number of pods that can be unavailable during disruptions (mutually exclusive with minAvailable) |
| podDisruptionBudget.minAvailable | int | `1` | Minimum number of pods that must be available during disruptions (mutually exclusive with maxUnavailable) |
| podLabels | object | `{}` | Additional labels to add to pods |
| podSecurityContext | object | `{"enabled":true,"fsGroup":1001,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001}` | Pod security context configuration |
| podSecurityContext.enabled | bool | `true` | Enable pod security context |
| postgres | object | `{"database":"","externalPayloadStorage":{"conductorUrl":"","maxDataDays":0,"maxDataMonths":0,"maxDataRows":9223372036854775807,"maxDataYears":1,"tableName":"external.external_payload"},"host":"","password":"","port":5432,"username":""}` | PostgreSQL configuration |
| postgres.database | string | `""` | PostgreSQL database name |
| postgres.externalPayloadStorage | object | `{"conductorUrl":"","maxDataDays":0,"maxDataMonths":0,"maxDataRows":9223372036854775807,"maxDataYears":1,"tableName":"external.external_payload"}` | External payload storage configuration for PostgreSQL |
| postgres.externalPayloadStorage.conductorUrl | string | `""` | Conductor URL |
| postgres.externalPayloadStorage.maxDataDays | int | `0` | Max data days |
| postgres.externalPayloadStorage.maxDataMonths | int | `0` | Max data months |
| postgres.externalPayloadStorage.maxDataRows | int | `9223372036854775807` | Max data rows |
| postgres.externalPayloadStorage.maxDataYears | int | `1` | Max data years |
| postgres.externalPayloadStorage.tableName | string | `"external.external_payload"` | Table name |
| postgres.host | string | `""` | PostgreSQL host |
| postgres.password | string | `""` | PostgreSQL password |
| postgres.port | int | `5432` | PostgreSQL port |
| postgres.username | string | `""` | PostgreSQL username |
| priorityClassName | string | `""` | Pod priority class name |
| queue | object | `{"type":"redis_standalone"}` | Queue configuration |
| queue.type | string | `"redis_standalone"` | Queue type (redis_standalone, redis_cluster, redis_sentinel, postgres, memory) |
| queues | object | `{"dynomiteThreads":10}` | Queues configuration |
| queues.dynomiteThreads | int | `10` | Number of threads allocated to Dynomite queues |
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/health","port":8080},"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":10}` | Readiness probe configuration |
| readinessProbe.enabled | bool | `true` | Enable readiness probe |
| redis | object | `{"availabilityZone":"us-east-1c","host":"","hosts":"","masterName":"","maxIdleConnections":"","minEvictableIdleTimeMillis":"","minIdleConnections":"","numTestsPerEvictionRun":"","password":"","port":6379,"queueNamespacePrefix":"conductor_queues","queuesNonQuorumPort":22122,"ssl":false,"taskDefCacheRefreshInterval":1,"testWhileIdle":"","timeBetweenEvictionRunsMillis":"","workflowNamespacePrefix":"conductor"}` | Redis configuration |
| redis.availabilityZone | string | `"us-east-1c"` | Availability zone/rack for the Redis node |
| redis.host | string | `""` | Redis host |
| redis.hosts | string | `""` | List of redis hosts (host:port). Overrides host/port if set |
| redis.masterName | string | `""` | Redis Sentinel master name |
| redis.maxIdleConnections | string | `""` | Maximum idle connections in the pool |
| redis.minEvictableIdleTimeMillis | string | `""` | Minimum time an idle connection can sit in the pool before eviction (ms) |
| redis.minIdleConnections | string | `""` | Minimum idle connections in the pool |
| redis.numTestsPerEvictionRun | string | `""` | Number of connections to test per eviction run |
| redis.password | string | `""` | Redis password |
| redis.port | int | `6379` | Redis port |
| redis.queueNamespacePrefix | string | `"conductor_queues"` | Queue namespace prefix |
| redis.queuesNonQuorumPort | int | `22122` | Non-quorum port used to connect to local Redis (used by Dynomite queues) |
| redis.ssl | bool | `false` | Enable SSL/TLS |
| redis.taskDefCacheRefreshInterval | int | `1` | Task definition cache refresh interval |
| redis.testWhileIdle | string | `""` | Whether to validate connections while idle |
| redis.timeBetweenEvictionRunsMillis | string | `""` | Time between eviction runs (ms, -1 to disable) |
| redis.workflowNamespacePrefix | string | `"conductor"` | Workflow namespace prefix |
| replicaCount | int | `1` | Number of pods |
| resources | object | `{"limits":{"cpu":"2","memory":"3Gi"},"requests":{"cpu":"300m","memory":"2Gi"}}` | Main container requests/limits  memory calculation: onHeapMb (JVM Heap max size)   + maxMetaspaceSizeMb (JVM Metaspace max size)   + reservedCodeCacheSizeMb (JVM ReservedCodeCache size)   + maxDirectMemorySizeMb (JVM DirectMemory max size)   + ~512MB (other overheads; e.g., thread stacks, GC, symbols, etc.) |
| revisionHistoryLimit | int | `10` | Number of old ReplicaSets to retain |
| security | object | `{"auth":{"basic":{"enabled":false,"principal":"","realm":"","role":""},"oidc":{"audience":"","clientId":"","clientSecret":"","discoveryUri":"","enabled":false,"groupsClaim":"groups"}},"enabled":false}` | Security configuration (IAM/Auth) |
| security.auth.basic.enabled | bool | `false` | Enable Basic authentication |
| security.auth.basic.principal | string | `""` | Basic Auth Principal |
| security.auth.basic.realm | string | `""` | Basic Auth Realm |
| security.auth.basic.role | string | `""` | Basic Auth Role |
| security.auth.oidc.audience | string | `""` | OIDC Audience |
| security.auth.oidc.clientId | string | `""` | OIDC Client ID |
| security.auth.oidc.clientSecret | string | `""` | OIDC Client Secret (can be provided via secret) |
| security.auth.oidc.discoveryUri | string | `""` | OIDC Discovery URI |
| security.auth.oidc.enabled | bool | `false` | Enable OIDC authentication |
| security.auth.oidc.groupsClaim | string | `"groups"` | OIDC Groups Claim |
| security.enabled | bool | `false` | Enable security |
| service.nodePorts.grpc | string | `""` | NodePort value for gRPC when service.type is NodePort |
| service.nodePorts.rest | string | `""` | NodePort value for REST API when service.type is NodePort |
| service.nodePorts.ui | string | `""` | NodePort value for UI when service.type is NodePort |
| service.ports | object | `{"rest":8080,"ui":5000}` | Service ports used by the Service spec. targetPort fields reference container.ports.* |
| service.ports.rest | int | `8080` | Service port for REST API |
| service.ports.ui | int | `5000` | Service port for UI |
| service.type | string | `"ClusterIP"` | Service type (ClusterIP, NodePort, LoadBalancer) |
| serviceAccount.annotations | object | `{}` | Additional annotations to add to ServiceAccount |
| serviceAccount.create | bool | `true` | Create a dedicated ServiceAccount |
| serviceAccount.name | string | `""` | Name for the ServiceAccount (autogenerated when empty) |
| spring | object | `{"apiDocsPath":"/api-docs","profilesActive":"logrotate"}` | Spring configuration |
| spring.apiDocsPath | string | `"/api-docs"` | Path to the API docs endpoint |
| spring.profilesActive | string | `"logrotate"` | Profiles passed via SPRING_PROFILES_ACTIVE |
| startupProbe | object | `{"enabled":true,"failureThreshold":15,"httpGet":{"path":"/health","port":8080},"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Startup probe configuration |
| startupProbe.enabled | bool | `true` | Enable startup probe |
| statusListener | object | `{"taskType":"","workflowType":""}` | Status listener configuration (webhook notifications) |
| statusListener.taskType | string | `""` | Task status listener type (e.g., task_publisher) |
| statusListener.workflowType | string | `""` | Workflow status listener type (e.g., workflow_publisher) |
| statusNotifier | object | `{"connectionPoolMaxRequest":"","connectionPoolMaxRequestPerRoute":"","endpointTask":"","endpointWorkflow":"","headerPrefer":"","headerPreferValue":"","requestRetryCount":"","requestRetryIntervalMs":"","requestTimeoutMsConnMgr":"","requestTimeoutMsConnect":"","requestTimeoutMsRead":"","subscribedTaskStatuses":"","url":""}` | Status notifier configuration |
| statusNotifier.connectionPoolMaxRequest | string | `""` | Max concurrent requests |
| statusNotifier.connectionPoolMaxRequestPerRoute | string | `""` | Max concurrent requests per route |
| statusNotifier.endpointTask | string | `""` | Webhook endpoint for task status |
| statusNotifier.endpointWorkflow | string | `""` | Webhook endpoint for workflow status |
| statusNotifier.headerPrefer | string | `""` | Custom header name |
| statusNotifier.headerPreferValue | string | `""` | Custom header value |
| statusNotifier.requestRetryCount | string | `""` | Number of retries |
| statusNotifier.requestRetryIntervalMs | string | `""` | Retry interval in ms |
| statusNotifier.requestTimeoutMsConnMgr | string | `""` | Connection manager timeout in ms |
| statusNotifier.requestTimeoutMsConnect | string | `""` | Connection timeout in ms |
| statusNotifier.requestTimeoutMsRead | string | `""` | Read timeout in ms |
| statusNotifier.subscribedTaskStatuses | string | `""` | Subscribed task statuses (e.g., SCHEDULED) |
| statusNotifier.url | string | `""` | Webhook notification URL |
| terminationGracePeriodSeconds | int | `60` | Pod termination grace period |
| tolerations | list | `[]` | Node tolerations |
| topologySpreadConstraints | list | `[]` | Topology spread constraints |
| updateStrategy | object | `{"type":"RollingUpdate"}` | Deployment update strategy (type only is used) |
| workflowArchival | object | `{"delay":"1h","enabled":false,"ttl":"30d","type":"elasticsearch"}` | Workflow archival configuration |
| workflowArchival.delay | string | `"1h"` | Delay before archiving a completed workflow |
| workflowArchival.enabled | bool | `false` | Enable workflow archival |
| workflowArchival.ttl | string | `"30d"` | Time to live for archived workflows |
| workflowArchival.type | string | `"elasticsearch"` | Archival type (e.g., elasticsearch, opensearch) |
| workflowExecutionLock | object | `{"type":"redis"}` | Workflow execution lock configuration |
| workflowExecutionLock.type | string | `"redis"` | Workflow execution lock type (redis, postgres, local_only, noop_lock) |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
