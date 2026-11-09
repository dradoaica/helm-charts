# conductor-oss-conductor

![Version: 3.33.2](https://img.shields.io/badge/Version-3.33.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.33.0](https://img.shields.io/badge/AppVersion-3.33.0-informational?style=flat-square)

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

## Configuration

The chart renders the Conductor properties into a ConfigMap (key `conductor.properties`), which Conductor loads at
startup (`CONDUCTOR_CONFIG_FILE`) as system properties; the credentials come from a Secret, through `${...}` placeholders
resolved from environment variables. Set any other property via `extraProperties` (flat names, e.g.,
`conductor.app.ownerEmailMandatory: true`). The chart requires the hosts of the configured backends (e.g., `redis.host`
and `elasticsearch.url` with the defaults) and fails with a message when one is missing or a type is not supported.

The `conductoross/conductor` image includes a single indexing backend, Elasticsearch 7: `indexing.type` elasticsearch8,
opensearch2 and opensearch3 require an image built with the matching `INDEXING_BACKEND` build argument (see the Conductor
`docker/server/Dockerfile`).

Conductor OSS has no authentication: restrict access to the API, UI and gRPC ports (e.g., with `networkPolicy.create`
and an authenticating proxy in front of the Ingress).

## Upgrading to 3.33.2

Chart 3.33.1 and earlier passed the configuration as environment variables named like the properties (e.g.,
`conductor.db.type`), which the image's shell (dash) drops before starting Java: Conductor ran with its built-in
defaults (SQLite in the pod) whatever the values. From 3.33.2, the configuration is applied, so check the values
against your backends before upgrading. Upgrade with `--reset-then-reuse-values` (not `--reuse-values`, which keeps
the 3.33.1 defaults and misses the new settings; the chart then fails with a message):

```shell
helm upgrade <release> <chart> --version 3.33.2 --reset-then-reuse-values
```

Also:

- The JVM options are passed as `JAVA_OPTS` (`memory.*` and `env.EXTRA_JVM_OPTS` now apply); the default heap is
  1536 MB and the memory request equals the limit (3Gi).
- The pods run with a read-only root filesystem (writable `emptyDir` volumes for `/tmp`, `/app/logs` and nginx), which
  also lets nginx serve the UI as a non-root user.
- The image runs Java under a shell that does not forward SIGTERM, so the pods used to be killed at the end of the
  termination grace period: a default `preStop` hook (`lifecycleHooks`) now signals Java, which shuts down gracefully
  (`gracefulShutdownTimeout`). An init container also discards `/app/logs/server.log`, a copy of the console output
  that the image's startup script appends to without rotation.
- `spring.profilesActive` defaults to empty (the `logrotate` profile does not exist in the image), and
  `management.endpointsWebExposureInclude` to Conductor's `health,info,prometheus` (the image's nginx also serves them
  under `/actuator` on the UI port).
- The event queues have their own switches (`amqpEventQueues.enabled`, `natsEventQueues.natsStream.enabled`,
  `natsEventQueues.jetStream.enabled`, `kafkaEventQueues.enabled`), so several systems can be used at once;
  `defaultEventQueue` still enables the queues of its type.
- With `networkPolicy.create`, the NetworkPolicy allows the chart's test pods (`allowTests`) and the egress to the
  ports of the configured backends (`allowBackends`).
- The pods prefer different nodes (`topologySpreadConstraints`).
- New settings: `redis.sentinelPassword`, and `postgres.urlParameters` / `mySql.urlParameters` (e.g., `sslmode=require`).
- Changed defaults: `grpcServer.enabled` (false, as the gRPC server never started with 3.33.1), the payload size
  thresholds and maximums of `app` (Conductor's, i.e., 3-5 MB and 10 MB instead of 1 MB and 4 GB; without
  `externalPayloadStorage.type`, the payloads beyond the thresholds are stored in the pod), `ai.enabled` (false), `management.healthShowDetails` (when_authorized), `management.healthRedisEnabled`
  (false, as Spring Boot's indicator checks localhost), `podDisruptionBudget` (`maxUnavailable: 1`, only with more than
  one replica), `autoscaling.targetMemoryUtilizationPercentage` (disabled); the pods no longer mount the ServiceAccount token nor
  get the Service environment variables.
- Removed values that Conductor OSS does not read: `cors`, `security`, `zookeeperLock`, `queues.dynomiteThreads`,
  `app.enableRemoveRedisKey`, `app.ttlRedisKeyExpire`, `redis.queuesNonQuorumPort`, `cassandra.localDatacenter`,
  `elasticsearch.indexName`, `openSearch.indexName` and `openSearch.version`, the `restClientConnectionTimeout` and
  `restClientReadTimeout` of `elasticsearch` and `openSearch`, `amqpEventQueues.maxPriority` (a per-queue URI parameter),
  `metrics.loggerReportPeriodSeconds` and `metrics.prometheusEnabled` (`metrics.enabled` now adds the prometheus.io pod
  annotations).
- No longer supported types: `db.type` memory (it does not start with Conductor 3.33; use sqlite) and `indexing.type`
  opensearch (Conductor fails at startup; use opensearch2 or opensearch3).
- `workflowArchival` configures the archive workflow status listener (`type` DEFAULT or S3, `ttl`, `delaySeconds`,
  `unsuccessfulOnly`, S3 bucket), combined with `statusListener.workflowType` when both are set; `workflowArchival.delay`
  is replaced by `delaySeconds`.
- The AI API keys (but Bedrock's) are passed as the environment variables read by Conductor (e.g., `OPENAI_API_KEY`), and
  `ai.bedrock.region`, `ai.gemini.location` and `ai.ollama.baseUrl` default to Conductor's own defaults (which read
  `AWS_REGION`, `GOOGLE_CLOUD_LOCATION` and `OLLAMA_BASE_URL`/`OLLAMA_HOST`).
- `elasticsearch.indexReplicasCount` defaults to 1 (Conductor's default), and `podDisruptionBudget.minAvailable`, when set,
  takes precedence over `maxUnavailable`.
- `externalPayloadStorage.type` is `azureblob` (`azure_blob` still works), and empty instead of `null` for none.
- With `secrets.existingSecret`, the optional credentials (all but the Redis, MySQL and PostgreSQL passwords) are
  referenced as optional keys, so they no longer need to be set in the values too.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Node affinity |
| ai | object | `{"anthropic":{"apiKey":""},"azureOpenAI":{"apiKey":"","baseUrl":"","deploymentName":""},"bedrock":{"accessKey":"","bearerToken":"","region":"","secretKey":""},"cohere":{"apiKey":""},"decision":{"apiKey":"","apiShape":"","provider":""},"enabled":false,"gemini":{"apiKey":"","applicationCredentials":"","credentialsSecret":{"key":"","name":""},"location":"","projectID":""},"grok":{"apiKey":""},"huggingFace":{"apiKey":""},"mistral":{"apiKey":""},"ollama":{"baseUrl":""},"openAI":{"apiKey":"","organizationID":""},"outbound":{"allowPrivateNetworks":false,"allowedOrigins":""},"perplexity":{"apiKey":""},"stabilityAI":{"apiKey":""}}` | AI configuration |
| ai.anthropic | object | `{"apiKey":""}` | Anthropic configuration |
| ai.anthropic.apiKey | string | `""` | Anthropic API key |
| ai.azureOpenAI | object | `{"apiKey":"","baseUrl":"","deploymentName":""}` | Azure OpenAI configuration |
| ai.azureOpenAI.apiKey | string | `""` | Azure OpenAI API key |
| ai.azureOpenAI.baseUrl | string | `""` | Azure OpenAI base URL |
| ai.azureOpenAI.deploymentName | string | `""` | Azure OpenAI deployment name |
| ai.bedrock | object | `{"accessKey":"","bearerToken":"","region":"","secretKey":""}` | AWS Bedrock configuration |
| ai.bedrock.accessKey | string | `""` | AWS access key ID |
| ai.bedrock.bearerToken | string | `""` | AWS Bedrock bearer token |
| ai.bedrock.region | string | `""` | AWS region (defaults to the AWS_REGION environment variable, or us-east-1) |
| ai.bedrock.secretKey | string | `""` | AWS secret access key |
| ai.cohere | object | `{"apiKey":""}` | Cohere configuration |
| ai.cohere.apiKey | string | `""` | Cohere API key |
| ai.decision | object | `{"apiKey":"","apiShape":"","provider":""}` | Structured decision inference configuration |
| ai.decision.apiKey | string | `""` | Decision inference API key |
| ai.decision.apiShape | string | `""` | Decision inference API shape (e.g., system-one) |
| ai.decision.provider | string | `""` | Decision inference provider (e.g., openrouter) |
| ai.enabled | bool | `false` | Enable the AI integrations (LLM tasks, MCP, agents) |
| ai.gemini | object | `{"apiKey":"","applicationCredentials":"","credentialsSecret":{"key":"","name":""},"location":"","projectID":""}` | Google Gemini configuration |
| ai.gemini.apiKey | string | `""` | Google Gemini API key |
| ai.gemini.applicationCredentials | string | `""` | Path to Google application credentials inside the container (e.g., mounted via extraVolumes) |
| ai.gemini.credentialsSecret | object | `{"key":"","name":""}` | Secret with the Google application credentials (a service account key), mounted for GOOGLE_APPLICATION_CREDENTIALS |
| ai.gemini.credentialsSecret.key | string | `""` | Key in the Secret that holds the credentials JSON (defaults to 'credentials.json') |
| ai.gemini.credentialsSecret.name | string | `""` | Name of the Secret (takes precedence over applicationCredentials) |
| ai.gemini.location | string | `""` | Google Cloud location (defaults to the GOOGLE_CLOUD_LOCATION environment variable, or us-central1) |
| ai.gemini.projectID | string | `""` | Google Cloud project ID |
| ai.grok | object | `{"apiKey":""}` | Grok configuration |
| ai.grok.apiKey | string | `""` | Grok API key |
| ai.huggingFace | object | `{"apiKey":""}` | HuggingFace configuration |
| ai.huggingFace.apiKey | string | `""` | HuggingFace API key |
| ai.mistral | object | `{"apiKey":""}` | Mistral configuration |
| ai.mistral.apiKey | string | `""` | Mistral API key |
| ai.ollama | object | `{"baseUrl":""}` | Ollama configuration |
| ai.ollama.baseUrl | string | `""` | Ollama base URL (defaults to the OLLAMA_BASE_URL or OLLAMA_HOST environment variable, or http://localhost:11434) |
| ai.openAI | object | `{"apiKey":"","organizationID":""}` | OpenAI configuration |
| ai.openAI.apiKey | string | `""` | OpenAI API key |
| ai.openAI.organizationID | string | `""` | OpenAI organization ID |
| ai.outbound | object | `{"allowPrivateNetworks":false,"allowedOrigins":""}` | Outbound access for external MCP servers and Conductor-Agents OpenAPI discovery (default-deny) |
| ai.outbound.allowPrivateNetworks | bool | `false` | Allow private network addresses for listed origins (development only) |
| ai.outbound.allowedOrigins | string | `""` | Exact origins allowed for outbound access (comma-separated, e.g., https://tools.example.com) |
| ai.perplexity | object | `{"apiKey":""}` | Perplexity configuration |
| ai.perplexity.apiKey | string | `""` | Perplexity API key |
| ai.stabilityAI | object | `{"apiKey":""}` | StabilityAI configuration |
| ai.stabilityAI.apiKey | string | `""` | StabilityAI API key |
| amqpEventQueues | object | `{"batchSize":1,"connectionTimeoutInMilliSecs":180000,"durable":false,"duration":1000,"enabled":false,"exclusive":false,"handshakeTimeoutInMilliSecs":180000,"hosts":"","limit":50,"listenerQueuePrefix":"","maxChannelCount":5000,"networkRecoveryIntervalInMilliSecs":5000,"password":"","pollTimeDuration":"100ms","port":5672,"queueType":"classic","requestHeartbeatTimeoutInSecs":30,"retryType":"REGULARINTERVALS","sequentialMsgProcessing":true,"useExchange":true,"useNio":false,"username":"","virtualHost":"/"}` | AMQP (RabbitMQ) Event Queues configuration |
| amqpEventQueues.batchSize | int | `1` | Batch size for message consumption |
| amqpEventQueues.connectionTimeoutInMilliSecs | int | `180000` | Connection timeout in ms |
| amqpEventQueues.durable | bool | `false` | Whether queues are durable |
| amqpEventQueues.duration | int | `1000` | Rate limit duration in ms |
| amqpEventQueues.enabled | bool | `false` | Enable the AMQP event queues (for event handlers and EVENT tasks; also enabled by defaultEventQueue.type amqp) |
| amqpEventQueues.exclusive | bool | `false` | Whether queues are exclusive |
| amqpEventQueues.handshakeTimeoutInMilliSecs | int | `180000` | Handshake timeout in ms |
| amqpEventQueues.hosts | string | `""` | RabbitMQ server host(s) |
| amqpEventQueues.limit | int | `50` | Rate limit |
| amqpEventQueues.listenerQueuePrefix | string | `""` | Listener queue prefix |
| amqpEventQueues.maxChannelCount | int | `5000` | Maximum channel count |
| amqpEventQueues.networkRecoveryIntervalInMilliSecs | int | `5000` | Network recovery interval in ms |
| amqpEventQueues.password | string | `""` | RabbitMQ password |
| amqpEventQueues.pollTimeDuration | string | `"100ms"` | Poll time duration (e.g., 100ms) |
| amqpEventQueues.port | int | `5672` | RabbitMQ port |
| amqpEventQueues.queueType | string | `"classic"` | Queue type (classic, quorum) |
| amqpEventQueues.requestHeartbeatTimeoutInSecs | int | `30` | Heartbeat timeout in seconds |
| amqpEventQueues.retryType | string | `"REGULARINTERVALS"` | Retry type (REGULARINTERVALS, EXPONENTIALBACKOFF, INCREMENTALINTERVALS) |
| amqpEventQueues.sequentialMsgProcessing | bool | `true` | Whether to process messages sequentially |
| amqpEventQueues.useExchange | bool | `true` | Whether to use exchange (true) or queue (false) |
| amqpEventQueues.useNio | bool | `false` | Whether to use NIO |
| amqpEventQueues.username | string | `""` | RabbitMQ username |
| amqpEventQueues.virtualHost | string | `"/"` | RabbitMQ virtual host |
| annotations | object | `{}` | Annotations to add to all resources |
| app | object | `{"activeWorkerLastPollTimeout":"","appID":"","asyncIndexingEnabled":"","asyncUpdateDelay":"","asyncUpdateShortRunningWorkflowDuration":"","eventExecutionIndexingEnabled":"","eventMessageIndexingEnabled":"","eventProcessorThreadCount":"","eventQueueLongPollTimeout":"","eventQueuePollCount":"","eventQueuePollInterval":"","eventQueueSchedulerPollThreadCount":"","executorServiceMaxThreadCount":"","isolatedSystemTaskWorkerThreadCount":"","lockLeaseTime":"","lockTimeToTry":500,"maxPostponeDurationSeconds":"","maxTaskInputPayloadSizeThreshold":"","maxTaskOutputPayloadSizeThreshold":"","maxWorkflowInputPayloadSizeThreshold":"","maxWorkflowOutputPayloadSizeThreshold":"","maxWorkflowVariablesPayloadSizeThreshold":"","ownerEmailMandatory":"","stack":"","summaryInputOutputJsonSerializationEnabled":"","sweeperQueuePopTimeout":"","sweeperSweepBatchSize":"","sweeperThreadCount":"","sweeperWorkflowPollTimeout":"","systemTaskMaxPollCount":20,"systemTaskPostponeThreshold":"","systemTaskQueuePopTimeout":"","systemTaskWorkerCallbackDuration":"","systemTaskWorkerExecutionNamespace":"","systemTaskWorkerPollInterval":"","systemTaskWorkerThreadCount":20,"taskExecLogIndexingEnabled":"","taskExecLogSizeLimit":"","taskExecutionPostponeDuration":"","taskIndexingEnabled":"","taskInputPayloadSizeThreshold":"","taskOutputPayloadSizeThreshold":"","taskWorkerConfigs":{},"workflowExecutionLockEnabled":true,"workflowInputPayloadSizeThreshold":"","workflowNameValidationEnabled":false,"workflowOffsetTimeout":"","workflowOutputPayloadSizeThreshold":"","workflowRepairServiceEnabled":false}` | App configuration |
| app.activeWorkerLastPollTimeout | string | `""` | The time to consider if a worker is actively polling for a task (e.g., 10s) |
| app.appID | string | `""` | The ID with which the app has been registered (e.g., conductor, myApp) |
| app.asyncIndexingEnabled | string | `""` | Whether to enable asynchronous indexing to Elasticsearch |
| app.asyncUpdateDelay | string | `""` | The delay with which short-running workflows will be updated in Elasticsearch when async indexing is enabled (e.g., 60s) |
| app.asyncUpdateShortRunningWorkflowDuration | string | `""` | The duration of workflow execution qualifying as short-running when async indexing to Elasticsearch is enabled (defaults to 30s) |
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
| app.maxTaskInputPayloadSizeThreshold | string | `""` | The maximum threshold of the task input payload size beyond which the task input will be rejected and the task marked as FAILED_WITH_TERMINAL_ERROR (defaults to 10240KB) |
| app.maxTaskOutputPayloadSizeThreshold | string | `""` | The maximum threshold of the task output payload size beyond which the task output will be rejected and the task marked as FAILED_WITH_TERMINAL_ERROR (defaults to 10240KB) |
| app.maxWorkflowInputPayloadSizeThreshold | string | `""` | The maximum threshold of the workflow input payload size beyond which input will be rejected and the workflow marked as FAILED (defaults to 10240KB) |
| app.maxWorkflowOutputPayloadSizeThreshold | string | `""` | The maximum threshold of the workflow output payload size beyond which output will be rejected and the workflow marked as FAILED (defaults to 10240KB) |
| app.maxWorkflowVariablesPayloadSizeThreshold | string | `""` | The maximum threshold of the workflow variables payload size beyond which the task changes will be rejected and the task marked as FAILED_WITH_TERMINAL_ERROR (defaults to 256KB) |
| app.ownerEmailMandatory | string | `""` | Whether to validate the owner email field as mandatory within workflow and task definitions |
| app.stack | string | `""` | Name of the stack within which the app is running (e.g., dev, testing, staging, prod) |
| app.summaryInputOutputJsonSerializationEnabled | string | `""` | Whether to enable summary input/output JSON serialization |
| app.sweeperQueuePopTimeout | string | `""` | Queue pop timeout in ms for sweeper (e.g., 100) |
| app.sweeperSweepBatchSize | string | `""` | Batch size per sweep poll (e.g., 2) |
| app.sweeperThreadCount | string | `""` | The number of threads to use for background sweeping on active workflows |
| app.sweeperWorkflowPollTimeout | string | `""` | The timeout for polling workflows to be swept (e.g., 2000ms, 2s) |
| app.systemTaskMaxPollCount | int | `20` | The maximum number of threads to be polled within the threadpool for system task workers |
| app.systemTaskPostponeThreshold | string | `""` | After these many polls, begin exponential backoff for system tasks (e.g., 200) |
| app.systemTaskQueuePopTimeout | string | `""` | Queue pop timeout in ms for system tasks (e.g., 100ms) |
| app.systemTaskWorkerCallbackDuration | string | `""` | The interval after which a system task will be checked by the system task worker for completion (e.g., 30s) |
| app.systemTaskWorkerExecutionNamespace | string | `""` | The namespace for the system task workers to provide instance-level isolation |
| app.systemTaskWorkerPollInterval | string | `""` | The interval at which system task queues will be polled by system task workers (e.g., 50ms) |
| app.systemTaskWorkerThreadCount | int | `20` | The number of threads in the threadpool for system task workers |
| app.taskExecLogIndexingEnabled | string | `""` | Whether to enable indexing of task execution logs |
| app.taskExecLogSizeLimit | string | `""` | The maximum size of task execution logs |
| app.taskExecutionPostponeDuration | string | `""` | The time for which a task execution will be postponed if rate-limited or concurrent execution limited (e.g., 60s) |
| app.taskIndexingEnabled | string | `""` | Whether to enable indexing of tasks |
| app.taskInputPayloadSizeThreshold | string | `""` | The threshold of the task input payload size beyond which the payload will be stored in ExternalPayloadStorage (defaults to 3072KB) |
| app.taskOutputPayloadSizeThreshold | string | `""` | The threshold of the task output payload size beyond which the payload will be stored in ExternalPayloadStorage (defaults to 3072KB) |
| app.taskWorkerConfigs | object | `{}` | Per-task-type system task worker settings, rendered as `conductor.app.taskWorkerConfigs.<TASK>.<setting>` (e.g., HTTP: { threadCount: 20 }) |
| app.workflowExecutionLockEnabled | bool | `true` | Whether to enable the workflow execution lock |
| app.workflowInputPayloadSizeThreshold | string | `""` | The threshold of the workflow input payload size beyond which the payload will be stored in ExternalPayloadStorage (defaults to 5120KB; without externalPayloadStorage.type, the payloads beyond the thresholds are stored in the pod, lost on restart and not shared between replicas) |
| app.workflowNameValidationEnabled | bool | `false` | Whether to enable workflow/task definition name validation |
| app.workflowOffsetTimeout | string | `""` | The timeout duration to set when a workflow is pushed to the decider queue (e.g., 30s, 1m) |
| app.workflowOutputPayloadSizeThreshold | string | `""` | The threshold of the workflow output payload size beyond which the payload will be stored in ExternalPayloadStorage (defaults to 5120KB) |
| app.workflowRepairServiceEnabled | bool | `false` | Whether to enable the (deprecated) workflow repair service |
| autoscaling.create | bool | `false` | Create a HorizontalPodAutoscaler |
| autoscaling.maxReplicas | int | `10` | Maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage |
| autoscaling.targetMemoryUtilizationPercentage | string | `""` | Target memory utilization percentage (not recommended, as the JVM pre-touches its whole heap, so the memory utilization stays high whatever the load) |
| azureBlob | object | `{"externalPayloadStorage":{"connectionString":"","containerName":"conductor-payloads","endpoint":"","sasToken":"","signedUrlExpirationSeconds":5,"taskInputPath":"task/input/","taskOutputPath":"task/output/","workflowInputPath":"workflow/input/","workflowOutputPath":"workflow/output/"}}` | Azure Blob configuration |
| azureBlob.externalPayloadStorage | object | `{"connectionString":"","containerName":"conductor-payloads","endpoint":"","sasToken":"","signedUrlExpirationSeconds":5,"taskInputPath":"task/input/","taskOutputPath":"task/output/","workflowInputPath":"workflow/input/","workflowOutputPath":"workflow/output/"}` | External payload storage configuration for Azure Blob |
| azureBlob.externalPayloadStorage.connectionString | string | `""` | Storage connection string (required to sign URLs) |
| azureBlob.externalPayloadStorage.containerName | string | `"conductor-payloads"` | Storage container name |
| azureBlob.externalPayloadStorage.endpoint | string | `""` | Storage endpoint (optional if connectionString is set) |
| azureBlob.externalPayloadStorage.sasToken | string | `""` | Storage SAS token (optional if connectionString is set) |
| azureBlob.externalPayloadStorage.signedUrlExpirationSeconds | int | `5` | Signed URL expiration in seconds |
| azureBlob.externalPayloadStorage.taskInputPath | string | `"task/input/"` | Path prefix for task input payloads |
| azureBlob.externalPayloadStorage.taskOutputPath | string | `"task/output/"` | Path prefix for task output payloads |
| azureBlob.externalPayloadStorage.workflowInputPath | string | `"workflow/input/"` | Path prefix for workflow input payloads |
| azureBlob.externalPayloadStorage.workflowOutputPath | string | `"workflow/output/"` | Path prefix for workflow output payloads |
| cassandra | object | `{"contactPoints":"","keyspace":"conductor","password":"","port":9042,"username":""}` | Cassandra configuration |
| cassandra.contactPoints | string | `""` | Cassandra contact points (comma-separated hostnames or IPs), rendered as conductor.cassandra.hostAddress |
| cassandra.keyspace | string | `"conductor"` | Cassandra keyspace |
| cassandra.password | string | `""` | Cassandra password |
| cassandra.port | int | `9042` | Cassandra port |
| cassandra.username | string | `""` | Cassandra username |
| container.ports | object | `{"grpc":8090,"rest":8080,"ui":5000}` | Container ports used by the Pod spec and as Service targetPort values (keep rest and ui as they are, as the image's nginx serves the UI on 5000 and proxies the API to localhost:8080) |
| containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}}` | Container security context configuration |
| containerSecurityContext.enabled | bool | `true` | Enable container security context |
| db | object | `{"type":"redis_standalone"}` | DB configuration |
| db.type | string | `"redis_standalone"` | DB type (redis_standalone, redis_cluster, redis_sentinel, mysql, postgres, cassandra, sqlite; sqlite keeps the data in the pod, lost on restart) |
| defaultEventQueue | object | `{"enabled":false,"type":"amqp"}` | Default event queue configuration (the queues Conductor listens on for WAIT/HUMAN task updates; enabling it also enables the event queues of its type) |
| defaultEventQueue.enabled | bool | `false` | Enable default event queue |
| defaultEventQueue.type | string | `"amqp"` | Default event queue type (amqp, nats_stream, jsm, kafka) |
| documentAccessPolicy | object | `{"allowedDirectories":"","blockedFileNames":"","blockedHosts":"","blockedPathPrefixes":"","disabled":false}` | Document access policy configuration |
| documentAccessPolicy.allowedDirectories | string | `""` | Additional directories allowed for local filesystem access (comma-separated) |
| documentAccessPolicy.blockedFileNames | string | `""` | File names added to the built-in blocklist (comma-separated) |
| documentAccessPolicy.blockedHosts | string | `""` | Hosts added to the built-in blocklist (comma-separated) |
| documentAccessPolicy.blockedPathPrefixes | string | `""` | Path prefixes added to the built-in blocklist (comma-separated) |
| documentAccessPolicy.disabled | bool | `false` | Disable document access policy checks (not recommended for production) |
| elasticsearch | object | `{"asyncBufferFlushTimeout":"10s","asyncMaxPoolSize":12,"asyncWorkerQueueSize":100,"clusterHealthColor":"yellow","indexBatchSize":1,"indexPrefix":"","indexReplicasCount":1,"indexShardCount":5,"password":"","restClientConnectionRequestTimeout":-1,"url":"","username":"","version":7}` | Elasticsearch configuration |
| elasticsearch.asyncBufferFlushTimeout | string | `"10s"` | Maximum time an async buffer is held before flushing (e.g., 10s) |
| elasticsearch.asyncMaxPoolSize | int | `12` | Maximum async indexing threads |
| elasticsearch.asyncWorkerQueueSize | int | `100` | Async indexing task queue depth |
| elasticsearch.clusterHealthColor | string | `"yellow"` | Elasticsearch cluster health color |
| elasticsearch.indexBatchSize | int | `1` | Documents per batch in async indexing mode |
| elasticsearch.indexPrefix | string | `""` | Elasticsearch index prefix |
| elasticsearch.indexReplicasCount | int | `1` | Elasticsearch index replicas count (0 has no redundancy; the cluster health stays yellow on a single node otherwise) |
| elasticsearch.indexShardCount | int | `5` | Elasticsearch primary shard count per index |
| elasticsearch.password | string | `""` | Elasticsearch password |
| elasticsearch.restClientConnectionRequestTimeout | int | `-1` | REST client connection request timeout in ms (-1 means unlimited) |
| elasticsearch.url | string | `""` | Elasticsearch URL |
| elasticsearch.username | string | `""` | Elasticsearch username |
| elasticsearch.version | int | `7` | Elasticsearch version (7 with indexing.type elasticsearch; use indexing.type elasticsearch8 for Elasticsearch 8) |
| env | object | `{"EXTRA_JVM_OPTS":""}` | Environment variables (EXTRA_JVM_OPTS is appended to JAVA_OPTS; the names must be valid shell identifiers, as the image starts Java from a shell, so set the Conductor/Spring properties via extraProperties, which take precedence) |
| externalPayloadStorage | object | `{"type":""}` | External payload storage configuration |
| externalPayloadStorage.type | string | `""` | External payload storage type (postgres, s3, azureblob, or empty for none; postgres uses the postgres.* connection) |
| extraContainers | list | `[]` | Extra sidecar containers to inject into the main Pod spec |
| extraEnvFrom | list | `[]` | Extra envFrom entries to inject into the main container |
| extraEnvVars | list | `[]` | Extra environment variables to inject into the main container |
| extraEnvVarsCM | string | `""` | Name of a ConfigMap with extra environment variables to inject into the main container |
| extraEnvVarsSecret | string | `""` | Name of a Secret with extra environment variables to inject into the main container |
| extraInitContainers | list | `[]` | Extra init containers to inject into the main Pod spec |
| extraProperties | object | `{}` | Extra Conductor/Spring properties (e.g., conductor.app.foo: bar), added to (and overriding) the chart's properties (an empty value removes the property) |
| extraVolumeMounts | list | `[]` | Extra volume mounts to add to the main container |
| extraVolumes | list | `[]` | Extra volumes to add to the main Pod spec |
| fullnameOverride | string | `""` | String to fully override the fullname template with a string |
| global.imagePullSecrets | list | `[]` | Global pod image pull secrets |
| global.imageRegistry | string | `""` | Global container image registry override |
| gracefulShutdownTimeout | string | `"30s"` | Maximum time Conductor waits for the in-flight requests on shutdown (Spring's graceful shutdown; keep the preStop delay in lifecycleHooks plus this timeout below terminationGracePeriodSeconds) |
| grpcServer | object | `{"enabled":false}` | GRPC Server configuration |
| grpcServer.enabled | bool | `false` | Enable GRPC server (listen port is `container.ports.grpc`) |
| image.pullPolicy | string | `"IfNotPresent"` | Main container image pull policy |
| image.registry | string | `"docker.io"` | Main container image registry |
| image.repository | string | `"conductoross/conductor"` | Main container image repository |
| image.tag | string | `""` | Main container image tag |
| indexing | object | `{"enabled":true,"type":"elasticsearch"}` | Indexing configuration |
| indexing.enabled | bool | `true` | Enable indexing |
| indexing.type | string | `"elasticsearch"` | Indexing type (elasticsearch, elasticsearch8, opensearch2, opensearch3, postgres, sqlite; postgres and sqlite require the same db.type, and elasticsearch8, opensearch2 and opensearch3 an image built with the INDEXING_BACKEND build argument, as the conductoross/conductor image only includes Elasticsearch 7) |
| ingress.annotations | object | `{}` | Additional annotations for the Ingress |
| ingress.className | string | `""` | IngressClass that will be used to implement the Ingress |
| ingress.create | bool | `false` | Create an Ingress for external HTTP access |
| ingress.hosts | list | `[{"host":"conductor-api.local","paths":[{"path":"/","pathType":"Prefix","portName":"rest"}]},{"host":"conductor-ui.local","paths":[{"path":"/","pathType":"Prefix","portName":"ui"}]}]` | List of Ingress hosts with paths for API and UI |
| ingress.tls | list | `[]` | TLS configuration for Ingress |
| kafkaEventQueues | object | `{"admin":{},"bootstrapServers":"kafka:29092","consumer":{},"dlqTopic":"conductor-dlq","enabled":false,"listenerQueuePrefix":"conductor_","pollTimeDuration":"500ms","producer":{}}` | Kafka Event Queues configuration |
| kafkaEventQueues.admin | object | `{}` | Kafka admin client properties |
| kafkaEventQueues.bootstrapServers | string | `"kafka:29092"` | Kafka bootstrap servers |
| kafkaEventQueues.consumer | object | `{}` | Kafka consumer client properties |
| kafkaEventQueues.dlqTopic | string | `"conductor-dlq"` | Dead letter queue topic |
| kafkaEventQueues.enabled | bool | `false` | Enable the Kafka event queues (also enabled by defaultEventQueue.type kafka) |
| kafkaEventQueues.listenerQueuePrefix | string | `"conductor_"` | Listener queue prefix |
| kafkaEventQueues.pollTimeDuration | string | `"500ms"` | Poll time duration (e.g., 500ms) |
| kafkaEventQueues.producer | object | `{}` | Kafka producer client properties |
| labels | object | `{}` | Additional labels to add to all resources |
| lifecycleHooks | object | `{"preStop":{"exec":{"command":["/bin/sh","-c","sleep 5; pid=$(pidof java) && kill -TERM $pid"]}}}` | Lifecycle hooks configuration (templated; as the image runs Java under a shell that does not forward SIGTERM, the default preStop hook waits for the Service to stop routing to the pod, then signals Java, and the container stops when Java has shut down) |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/health","port":"rest"},"initialDelaySeconds":5,"periodSeconds":30,"successThreshold":1,"timeoutSeconds":10}` | Liveness probe configuration |
| livenessProbe.enabled | bool | `true` | Enable liveness probe |
| logging | object | `{"level":{"root":"INFO"}}` | Logging configuration |
| logging.level.root | string | `"INFO"` | Root log level |
| management | object | `{"endpointsWebExposureInclude":"health,info,prometheus","healthElasticsearchEnabled":false,"healthRedisEnabled":false,"healthShowDetails":"when_authorized","metricsExport":{"atlas":false,"azureMonitor":false,"azureMonitorInstrumentationKey":"","cloudWatch":false,"cloudWatchNamespace":"conductor","datadog":false,"datadogApiKey":"","dynatrace":false,"elastic":false,"influx":false,"jmx":false,"newRelic":false,"otlp":false,"stackdriver":false,"stackdriverProjectID":"","statsD":false},"metricsPercentiles":"0.50,0.75,0.90,0.95,0.99"}` | Management configuration |
| management.endpointsWebExposureInclude | string | `"health,info,prometheus"` | Actuator endpoints to expose (comma-separated; the image's nginx also serves them under /actuator on the UI port) |
| management.healthElasticsearchEnabled | bool | `false` | Enable Spring Boot's Elasticsearch health indicator (it checks spring.elasticsearch, not Conductor's connection) |
| management.healthRedisEnabled | bool | `false` | Enable Spring Boot's Redis health indicator (it checks spring.data.redis, not Conductor's Redis connection) |
| management.healthShowDetails | string | `"when_authorized"` | Health endpoint detail level (never, when_authorized, always; always exposes backend details to anyone) |
| management.metricsExport | object | `{"atlas":false,"azureMonitor":false,"azureMonitorInstrumentationKey":"","cloudWatch":false,"cloudWatchNamespace":"conductor","datadog":false,"datadogApiKey":"","dynatrace":false,"elastic":false,"influx":false,"jmx":false,"newRelic":false,"otlp":false,"stackdriver":false,"stackdriverProjectID":"","statsD":false}` | Metrics export backends |
| management.metricsExport.atlas | bool | `false` | Enable Atlas metrics export |
| management.metricsExport.azureMonitor | bool | `false` | Enable Azure Monitor metrics export |
| management.metricsExport.azureMonitorInstrumentationKey | string | `""` | Azure Monitor Instrumentation Key (stored in the Secret) |
| management.metricsExport.cloudWatch | bool | `false` | Enable CloudWatch metrics export |
| management.metricsExport.cloudWatchNamespace | string | `"conductor"` | CloudWatch Namespace |
| management.metricsExport.datadog | bool | `false` | Enable Datadog metrics export |
| management.metricsExport.datadogApiKey | string | `""` | Datadog API Key (stored in the Secret) |
| management.metricsExport.dynatrace | bool | `false` | Enable Dynatrace metrics export |
| management.metricsExport.elastic | bool | `false` | Enable Elastic metrics export |
| management.metricsExport.influx | bool | `false` | Enable Influx metrics export |
| management.metricsExport.jmx | bool | `false` | Enable JMX metrics export |
| management.metricsExport.newRelic | bool | `false` | Enable New Relic metrics export |
| management.metricsExport.otlp | bool | `false` | Enable OTLP metrics export |
| management.metricsExport.stackdriver | bool | `false` | Enable Stackdriver metrics export |
| management.metricsExport.stackdriverProjectID | string | `""` | Stackdriver Project ID |
| management.metricsExport.statsD | bool | `false` | Enable StatsD metrics export |
| management.metricsPercentiles | string | `"0.50,0.75,0.90,0.95,0.99"` | Request metrics percentiles (comma-separated) |
| memory.g1HeapRegionSizeMB | string | `""` | JVM G1 Heap region size in MB. If not set, defaults to 1 |
| memory.maxDirectMemorySizeMB | string | `""` | JVM DirectMemory max size in MB. If not set, defaults to 256 |
| memory.maxMetaspaceSizeMB | string | `""` | JVM Metaspace max size in MB. If not set, defaults to 256 |
| memory.onHeapMB | string | `""` | On-heap memory limit in MB. If set, -Xms and -Xmx will be value. If not set, defaults to 1536 |
| memory.reservedCodeCacheSizeMB | string | `""` | JVM ReservedCodeCache size in MB. If not set, defaults to 240 |
| metrics | object | `{"enabled":false,"loggerEnabled":false}` | Metrics configuration |
| metrics.enabled | bool | `false` | Add the prometheus.io pod annotations for scraping /actuator/prometheus (requires prometheus in management.endpointsWebExposureInclude) |
| metrics.loggerEnabled | bool | `false` | Enable metrics logging |
| mySql | object | `{"database":"","deadlockRetryMax":"","host":"","password":"","port":3306,"taskDefCacheRefreshInterval":"","urlParameters":"","username":""}` | MySQL configuration |
| mySql.database | string | `""` | MySQL database name |
| mySql.deadlockRetryMax | string | `""` | MySQL deadlock retry max attempts |
| mySql.host | string | `""` | MySQL host |
| mySql.password | string | `""` | MySQL password |
| mySql.port | int | `3306` | MySQL port |
| mySql.taskDefCacheRefreshInterval | string | `""` | Task definition cache refresh interval (e.g., 60s) |
| mySql.urlParameters | string | `""` | Extra JDBC URL parameters (e.g., sslMode=REQUIRED&serverTimezone=UTC) |
| mySql.username | string | `""` | MySQL username |
| nameOverride | string | `""` | String to partially override the fullname template with a string (will prepend the release name) |
| natsEventQueues | object | `{"jetStream":{"durableName":"defaultQueue","enabled":false,"listenerQueuePrefix":"","replicas":3,"streamStorageType":"file","url":"nats://localhost:4222"},"natsStream":{"clusterID":"test-cluster","durableName":"","enabled":false,"listenerQueuePrefix":"","url":"nats://localhost:4222"}}` | NATS Event Queues configuration |
| natsEventQueues.jetStream.durableName | string | `"defaultQueue"` | JetStream durable consumer name |
| natsEventQueues.jetStream.enabled | bool | `false` | Enable the NATS JetStream event queues (also enabled by defaultEventQueue.type jsm) |
| natsEventQueues.jetStream.listenerQueuePrefix | string | `""` | Listener queue prefix |
| natsEventQueues.jetStream.replicas | int | `3` | JetStream stream replicas |
| natsEventQueues.jetStream.streamStorageType | string | `"file"` | JetStream stream storage type (file, memory) |
| natsEventQueues.jetStream.url | string | `"nats://localhost:4222"` | NATS JetStream URL |
| natsEventQueues.natsStream.clusterID | string | `"test-cluster"` | NATS streaming cluster ID |
| natsEventQueues.natsStream.durableName | string | `""` | NATS streaming durable name |
| natsEventQueues.natsStream.enabled | bool | `false` | Enable the NATS Streaming event queues (also enabled by defaultEventQueue.type nats_stream) |
| natsEventQueues.natsStream.listenerQueuePrefix | string | `""` | Listener queue prefix |
| natsEventQueues.natsStream.url | string | `"nats://localhost:4222"` | NATS streaming URL |
| networkPolicy.allowBackends | bool | `true` | Allow egress to the ports of the configured backends on any host (Redis, the database, the indexing backend, the event queues; other destinations, e.g., webhooks, payload storage, AI providers or Kafka brokers advertising other ports than the bootstrap servers, need egress rules) |
| networkPolicy.allowTests | bool | `true` | Allow ingress from the chart's test pods (helm test) |
| networkPolicy.create | bool | `false` | Create a NetworkPolicy |
| networkPolicy.egress | list | `[{"ports":[{"port":53,"protocol":"UDP"},{"port":53,"protocol":"TCP"}],"to":[{"ipBlock":{"cidr":"0.0.0.0/0"}}]}]` | NetworkPolicy egress rules |
| networkPolicy.ingress | list | `[]` | NetworkPolicy ingress rules (add rules for clients that need access to the API/UI) |
| networkPolicy.name | string | `""` | Name for the NetworkPolicy (defaults to fullname when empty) |
| nodeSelector | object | `{}` | Node selector |
| openSearch | object | `{"asyncBufferFlushTimeout":"10s","asyncMaxPoolSize":12,"asyncWorkerQueueSize":100,"autoIndexManagementEnabled":true,"clusterHealthColor":"green","indexBatchSize":1,"indexPrefix":"","indexReplicasCount":0,"indexShardCount":5,"password":"","restClientConnectionRequestTimeout":-1,"taskLogResultLimit":10,"url":"","username":""}` | OpenSearch configuration |
| openSearch.asyncBufferFlushTimeout | string | `"10s"` | Maximum time async buffer is held before flushing (e.g., 10s) |
| openSearch.asyncMaxPoolSize | int | `12` | Maximum async indexing threads |
| openSearch.asyncWorkerQueueSize | int | `100` | Async indexing task queue depth |
| openSearch.autoIndexManagementEnabled | bool | `true` | Whether Conductor automatically manages indices |
| openSearch.clusterHealthColor | string | `"green"` | OpenSearch cluster health color |
| openSearch.indexBatchSize | int | `1` | Documents per batch in async indexing mode |
| openSearch.indexPrefix | string | `""` | OpenSearch index prefix |
| openSearch.indexReplicasCount | int | `0` | OpenSearch index replicas count (0 has no redundancy) |
| openSearch.indexShardCount | int | `5` | OpenSearch primary shard count per index |
| openSearch.password | string | `""` | OpenSearch password |
| openSearch.restClientConnectionRequestTimeout | int | `-1` | REST client connection request timeout in ms (-1 means unlimited) |
| openSearch.taskLogResultLimit | int | `10` | Maximum task log entries returned per search |
| openSearch.url | string | `""` | OpenSearch URL |
| openSearch.username | string | `""` | OpenSearch username |
| podAnnotations | object | `{}` | Additional annotations to add to pods |
| podDisruptionBudget.create | bool | `false` | Create a PodDisruptionBudget for high availability (only with more than one replica) |
| podDisruptionBudget.maxUnavailable | int | `1` | Maximum number of pods that can be unavailable during disruptions |
| podDisruptionBudget.minAvailable | string | `""` | Minimum number of pods that must be available during disruptions (if set, used instead of maxUnavailable) |
| podLabels | object | `{}` | Additional labels to add to pods |
| podSecurityContext | object | `{"enabled":true,"fsGroup":1001,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001}` | Pod security context configuration |
| podSecurityContext.enabled | bool | `true` | Enable pod security context |
| postgres | object | `{"asyncMaxPoolSize":"","asyncWorkerQueueSize":"","database":"","deadlockRetryMax":"","experimentalQueueNotify":"","experimentalQueueNotifyStalePeriod":"","externalPayloadStorage":{"conductorUrl":"","maxDataDays":0,"maxDataMonths":0,"maxDataRows":"9223372036854775807","maxDataYears":1,"tableName":"external.external_payload"},"host":"","onlyIndexOnStatusChange":"","password":"","pollDataCacheValidityPeriod":"","pollDataFlushInterval":"","port":5432,"schema":"","taskDefCacheRefreshInterval":"","urlParameters":"","username":""}` | PostgreSQL configuration |
| postgres.asyncMaxPoolSize | string | `""` | Maximum async indexing threads (Postgres persistence) |
| postgres.asyncWorkerQueueSize | string | `""` | Async indexing task queue depth (Postgres persistence) |
| postgres.database | string | `""` | PostgreSQL database name |
| postgres.deadlockRetryMax | string | `""` | PostgreSQL deadlock retry max attempts |
| postgres.experimentalQueueNotify | string | `""` | Enable LISTEN/NOTIFY based queues (experimental) |
| postgres.experimentalQueueNotifyStalePeriod | string | `""` | LISTEN/NOTIFY stale period in ms (e.g., 5000) |
| postgres.externalPayloadStorage | object | `{"conductorUrl":"","maxDataDays":0,"maxDataMonths":0,"maxDataRows":"9223372036854775807","maxDataYears":1,"tableName":"external.external_payload"}` | External payload storage configuration for PostgreSQL |
| postgres.externalPayloadStorage.conductorUrl | string | `""` | Conductor URL |
| postgres.externalPayloadStorage.maxDataDays | int | `0` | Max data days |
| postgres.externalPayloadStorage.maxDataMonths | int | `0` | Max data months |
| postgres.externalPayloadStorage.maxDataRows | string | `"9223372036854775807"` | Max data rows (a string, as larger numbers lose precision in YAML) |
| postgres.externalPayloadStorage.maxDataYears | int | `1` | Max data years |
| postgres.externalPayloadStorage.tableName | string | `"external.external_payload"` | Table name |
| postgres.host | string | `""` | PostgreSQL host |
| postgres.onlyIndexOnStatusChange | string | `""` | Only index workflow on status change |
| postgres.password | string | `""` | PostgreSQL password |
| postgres.pollDataCacheValidityPeriod | string | `""` | Poll data cache validity period in ms (e.g., 5000) |
| postgres.pollDataFlushInterval | string | `""` | Poll data flush interval in ms (e.g., 5000) |
| postgres.port | int | `5432` | PostgreSQL port |
| postgres.schema | string | `""` | PostgreSQL schema |
| postgres.taskDefCacheRefreshInterval | string | `""` | Task definition cache refresh interval (e.g., 60s) |
| postgres.urlParameters | string | `""` | Extra JDBC URL parameters (e.g., sslmode=require), also used for the external payload storage |
| postgres.username | string | `""` | PostgreSQL username |
| priorityClassName | string | `""` | Pod priority class name |
| queue | object | `{"type":"redis_standalone"}` | Queue configuration |
| queue.type | string | `"redis_standalone"` | Queue type (redis_standalone, redis_cluster, redis_sentinel, or the db.type for postgres, mysql and sqlite, which use their own queues; cassandra requires a Redis queue type) |
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/health","port":"rest"},"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":10}` | Readiness probe configuration |
| readinessProbe.enabled | bool | `true` | Enable readiness probe |
| redis | object | `{"availabilityZone":"us-east-1c","host":"","hosts":"","masterName":"","maxIdleConnections":"","minEvictableIdleTimeMillis":"","minIdleConnections":"","numTestsPerEvictionRun":"","password":"","port":6379,"queueNamespacePrefix":"conductor_queues","sentinelPassword":"","ssl":false,"taskDefCacheRefreshInterval":1,"testWhileIdle":"","timeBetweenEvictionRunsMillis":"","username":"","workflowNamespacePrefix":"conductor"}` | Redis configuration |
| redis.availabilityZone | string | `"us-east-1c"` | Availability zone/rack for the Redis node |
| redis.host | string | `""` | Redis host |
| redis.hosts | string | `""` | List of Redis hosts (host:port[:rack], separated by semicolons, the Sentinel nodes for redis_sentinel; the rack defaults to availabilityZone, and the chart appends the password). Overrides host/port if set |
| redis.masterName | string | `""` | Redis Sentinel master name |
| redis.maxIdleConnections | string | `""` | Maximum idle connections in the pool |
| redis.minEvictableIdleTimeMillis | string | `""` | Minimum time an idle connection can sit in the pool before eviction (ms) |
| redis.minIdleConnections | string | `""` | Minimum idle connections in the pool |
| redis.numTestsPerEvictionRun | string | `""` | Number of connections to test per eviction run |
| redis.password | string | `""` | Redis password (must not contain ':' or ';', as Conductor reads it from the host list) |
| redis.port | int | `6379` | Redis port (with redis_sentinel, the port of the master, also allowed by networkPolicy.allowBackends) |
| redis.queueNamespacePrefix | string | `"conductor_queues"` | Queue namespace prefix |
| redis.sentinelPassword | string | `""` | Password of the Redis Sentinel nodes themselves (when they require AUTH) |
| redis.ssl | bool | `false` | Enable SSL/TLS |
| redis.taskDefCacheRefreshInterval | int | `1` | Task definition cache refresh interval in seconds |
| redis.testWhileIdle | string | `""` | Whether to validate connections while idle |
| redis.timeBetweenEvictionRunsMillis | string | `""` | Time between eviction runs (ms, -1 to disable) |
| redis.username | string | `""` | Redis ACL username |
| redis.workflowNamespacePrefix | string | `"conductor"` | Workflow namespace prefix |
| redisLock | object | `{"namespace":"","serverMasterName":"","serverType":""}` | Redis lock configuration (used when workflowExecutionLock.type is redis) |
| redisLock.namespace | string | `""` | Redis lock namespace/key prefix |
| redisLock.serverMasterName | string | `""` | Redis Sentinel master name for the lock (defaults to redis.masterName) |
| redisLock.serverType | string | `""` | Redis lock server type (single, cluster, sentinel; defaults to the type matching db.type) |
| replicaCount | int | `1` | Number of pods |
| resources | object | `{"limits":{"cpu":"2","memory":"3Gi"},"requests":{"cpu":"300m","memory":"3Gi"}}` | Main container requests/limits  memory calculation: onHeapMB (JVM Heap max size)   + maxMetaspaceSizeMB (JVM Metaspace max size)   + reservedCodeCacheSizeMB (JVM ReservedCodeCache size)   + maxDirectMemorySizeMB (JVM DirectMemory max size)   + ~512MB (other overheads; e.g., thread stacks, GC, symbols, nginx serving the UI, etc.)  The JVM pre-touches its whole heap at startup, so request the memory limit |
| revisionHistoryLimit | int | `10` | Number of old ReplicaSets to retain |
| s3 | object | `{"externalPayloadStorage":{"bucketName":"","region":"","signedUrlExpirationDuration":5}}` | Amazon S3 configuration |
| s3.externalPayloadStorage | object | `{"bucketName":"","region":"","signedUrlExpirationDuration":5}` | External payload storage configuration for Amazon S3 |
| s3.externalPayloadStorage.bucketName | string | `""` | Bucket name where payloads will be stored |
| s3.externalPayloadStorage.region | string | `""` | AWS region of the bucket |
| s3.externalPayloadStorage.signedUrlExpirationDuration | int | `5` | Signed URL expiration duration in seconds |
| scheduler | object | `{"enabled":true}` | Scheduler configuration |
| scheduler.enabled | bool | `true` | Enable the scheduler |
| secrets | object | `{"existingSecret":{"keys":{"aiAnthropicApiKey":"","aiAzureOpenAiApiKey":"","aiBedrockAccessKey":"","aiBedrockBearerToken":"","aiBedrockSecretKey":"","aiCohereApiKey":"","aiDecisionApiKey":"","aiGeminiApiKey":"","aiGrokApiKey":"","aiHuggingFaceApiKey":"","aiMistralApiKey":"","aiOpenAiApiKey":"","aiPerplexityApiKey":"","aiStabilityAiApiKey":"","amqpPassword":"","azureBlobConnectionString":"","azureBlobSasToken":"","azureMonitorInstrumentationKey":"","cassandraPassword":"","datadogApiKey":"","elasticsearchPassword":"","mySqlPassword":"","openSearchPassword":"","postgresPassword":"","redisPassword":"","redisSentinelPassword":""},"name":""},"manageSecret":true}` | Secrets |
| secrets.existingSecret | object | `{"keys":{"aiAnthropicApiKey":"","aiAzureOpenAiApiKey":"","aiBedrockAccessKey":"","aiBedrockBearerToken":"","aiBedrockSecretKey":"","aiCohereApiKey":"","aiDecisionApiKey":"","aiGeminiApiKey":"","aiGrokApiKey":"","aiHuggingFaceApiKey":"","aiMistralApiKey":"","aiOpenAiApiKey":"","aiPerplexityApiKey":"","aiStabilityAiApiKey":"","amqpPassword":"","azureBlobConnectionString":"","azureBlobSasToken":"","azureMonitorInstrumentationKey":"","cassandraPassword":"","datadogApiKey":"","elasticsearchPassword":"","mySqlPassword":"","openSearchPassword":"","postgresPassword":"","redisPassword":"","redisSentinelPassword":""},"name":""}` | Use an existing Secret for all credential keys instead of a chart-managed Secret (the Redis, MySQL and PostgreSQL passwords are required keys when used; the others are optional) |
| secrets.existingSecret.keys | object | `{"aiAnthropicApiKey":"","aiAzureOpenAiApiKey":"","aiBedrockAccessKey":"","aiBedrockBearerToken":"","aiBedrockSecretKey":"","aiCohereApiKey":"","aiDecisionApiKey":"","aiGeminiApiKey":"","aiGrokApiKey":"","aiHuggingFaceApiKey":"","aiMistralApiKey":"","aiOpenAiApiKey":"","aiPerplexityApiKey":"","aiStabilityAiApiKey":"","amqpPassword":"","azureBlobConnectionString":"","azureBlobSasToken":"","azureMonitorInstrumentationKey":"","cassandraPassword":"","datadogApiKey":"","elasticsearchPassword":"","mySqlPassword":"","openSearchPassword":"","postgresPassword":"","redisPassword":"","redisSentinelPassword":""}` | Optional mapping to override the expected key names in the existing Secret |
| secrets.existingSecret.keys.aiAnthropicApiKey | string | `""` | Key name for Anthropic API key (defaults to 'ai-anthropic-api-key') |
| secrets.existingSecret.keys.aiAzureOpenAiApiKey | string | `""` | Key name for Azure OpenAI API key (defaults to 'ai-azure-open-ai-api-key') |
| secrets.existingSecret.keys.aiBedrockAccessKey | string | `""` | Key name for Bedrock access key (defaults to 'ai-bedrock-access-key') |
| secrets.existingSecret.keys.aiBedrockBearerToken | string | `""` | Key name for Bedrock bearer token (defaults to 'ai-bedrock-bearer-token') |
| secrets.existingSecret.keys.aiBedrockSecretKey | string | `""` | Key name for Bedrock secret key (defaults to 'ai-bedrock-secret-key') |
| secrets.existingSecret.keys.aiCohereApiKey | string | `""` | Key name for Cohere API key (defaults to 'ai-cohere-api-key') |
| secrets.existingSecret.keys.aiDecisionApiKey | string | `""` | Key name for decision inference API key (defaults to 'ai-decision-api-key') |
| secrets.existingSecret.keys.aiGeminiApiKey | string | `""` | Key name for Gemini API key (defaults to 'ai-gemini-api-key') |
| secrets.existingSecret.keys.aiGrokApiKey | string | `""` | Key name for Grok API key (defaults to 'ai-grok-api-key') |
| secrets.existingSecret.keys.aiHuggingFaceApiKey | string | `""` | Key name for Hugging Face API key (defaults to 'ai-hugging-face-api-key') |
| secrets.existingSecret.keys.aiMistralApiKey | string | `""` | Key name for Mistral API key (defaults to 'ai-mistral-api-key') |
| secrets.existingSecret.keys.aiOpenAiApiKey | string | `""` | Key name for OpenAI API key (defaults to 'ai-open-ai-api-key') |
| secrets.existingSecret.keys.aiPerplexityApiKey | string | `""` | Key name for Perplexity API key (defaults to 'ai-perplexity-api-key') |
| secrets.existingSecret.keys.aiStabilityAiApiKey | string | `""` | Key name for Stability AI API key (defaults to 'ai-stability-ai-api-key') |
| secrets.existingSecret.keys.amqpPassword | string | `""` | Key name for AMQP password (defaults to 'amqp-password') |
| secrets.existingSecret.keys.azureBlobConnectionString | string | `""` | Key name for Azure Blob connection string (defaults to 'azure-blob-connection-string') |
| secrets.existingSecret.keys.azureBlobSasToken | string | `""` | Key name for Azure Blob SAS token (defaults to 'azure-blob-sas-token') |
| secrets.existingSecret.keys.azureMonitorInstrumentationKey | string | `""` | Key name for Azure Monitor instrumentation key (defaults to 'azure-monitor-instrumentation-key') |
| secrets.existingSecret.keys.cassandraPassword | string | `""` | Key name for Cassandra password (defaults to 'cassandra-password') |
| secrets.existingSecret.keys.datadogApiKey | string | `""` | Key name for Datadog API key (defaults to 'datadog-api-key') |
| secrets.existingSecret.keys.elasticsearchPassword | string | `""` | Key name for Elasticsearch password (defaults to 'elasticsearch-password') |
| secrets.existingSecret.keys.mySqlPassword | string | `""` | Key name for MySQL password (defaults to 'my-sql-password') |
| secrets.existingSecret.keys.openSearchPassword | string | `""` | Key name for OpenSearch password (defaults to 'open-search-password') |
| secrets.existingSecret.keys.postgresPassword | string | `""` | Key name for PostgreSQL password (defaults to 'postgres-password') |
| secrets.existingSecret.keys.redisPassword | string | `""` | Key name for Redis password (defaults to 'redis-password') |
| secrets.existingSecret.keys.redisSentinelPassword | string | `""` | Key name for Redis Sentinel password (defaults to 'redis-sentinel-password') |
| secrets.existingSecret.name | string | `""` | Name of the existing Secret containing the credentials |
| secrets.manageSecret | bool | `true` | When true (default), the chart creates its own Secret from values when no existingSecret is specified (when false, create a Secret named like the release fullname with the same keys) |
| service.nodePorts.grpc | string | `""` | NodePort value for gRPC when service.type is NodePort |
| service.nodePorts.rest | string | `""` | NodePort value for REST API when service.type is NodePort |
| service.nodePorts.ui | string | `""` | NodePort value for UI when service.type is NodePort |
| service.ports | object | `{"grpc":8090,"rest":8080,"ui":5000}` | Service ports used by the Service spec. targetPort fields reference container.ports.* |
| service.ports.grpc | int | `8090` | Service port for gRPC |
| service.ports.rest | int | `8080` | Service port for REST API |
| service.ports.ui | int | `5000` | Service port for UI |
| service.type | string | `"ClusterIP"` | Service type (ClusterIP, NodePort, LoadBalancer) |
| serviceAccount.annotations | object | `{}` | Additional annotations to add to ServiceAccount |
| serviceAccount.create | bool | `true` | Create a dedicated ServiceAccount |
| serviceAccount.name | string | `""` | Name for the ServiceAccount (autogenerated when empty) |
| spring | object | `{"allowBeanDefinitionOverriding":true,"apiDocsPath":"/api-docs","applicationName":"conductor","profilesActive":""}` | Spring configuration |
| spring.allowBeanDefinitionOverriding | bool | `true` | Allow Spring bean definition overriding |
| spring.apiDocsPath | string | `"/api-docs"` | Path to the API docs endpoint |
| spring.applicationName | string | `"conductor"` | Spring application name |
| spring.profilesActive | string | `""` | Profiles passed via SPRING_PROFILES_ACTIVE (the image has none of its own; Conductor logs to the console) |
| startupProbe | object | `{"enabled":true,"failureThreshold":15,"httpGet":{"path":"/health","port":"rest"},"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Startup probe configuration |
| startupProbe.enabled | bool | `true` | Enable startup probe |
| statusListener | object | `{"taskType":"","workflowType":""}` | Status listener configuration (webhook notifications) |
| statusListener.taskType | string | `""` | Task status listener type (e.g., task_publisher) |
| statusListener.workflowType | string | `""` | Workflow status listener type (e.g., workflow_publisher) |
| statusNotifier | object | `{"connectionPoolMaxRequest":"","connectionPoolMaxRequestPerRoute":"","endpointTask":"","endpointWorkflow":"","headerPrefer":"","headerPreferValue":"","requestRetryCount":"","requestRetryIntervalMs":"","requestTimeoutMsConnMgr":"","requestTimeoutMsConnect":"","requestTimeoutMsRead":"","subscribedTaskStatuses":"","subscribedWorkflowStatuses":"","url":""}` | Status notifier configuration |
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
| statusNotifier.subscribedTaskStatuses | string | `""` | Subscribed task statuses (comma-separated, e.g., SCHEDULED,COMPLETED) |
| statusNotifier.subscribedWorkflowStatuses | string | `""` | Subscribed workflow statuses (comma-separated, e.g., COMPLETED,FAILED) |
| statusNotifier.url | string | `""` | Webhook notification URL |
| terminationGracePeriodSeconds | int | `60` | Pod termination grace period |
| tolerations | list | `[]` | Node tolerations |
| topologySpreadConstraints | list | `[{"labelSelector":{"matchLabels":{"app.kubernetes.io/instance":"{{ .Release.Name }}","app.kubernetes.io/name":"{{ include \"conductor-oss-conductor.name\" . }}"}},"maxSkew":1,"topologyKey":"kubernetes.io/hostname","whenUnsatisfiable":"ScheduleAnyway"}]` | Topology spread constraints (templated; by default, the pods prefer different Kubernetes nodes) |
| updateStrategy | object | `{"type":"RollingUpdate"}` | Deployment update strategy |
| workflowArchival | object | `{"delayQueueWorkerThreadCount":"","delaySeconds":"","enabled":false,"s3BucketName":"","s3BucketRegion":"","ttl":"","type":"DEFAULT","unsuccessfulOnly":false}` | Workflow archival configuration (an archive workflow status listener, which removes the completed workflows from the primary storage; combined with statusListener.workflowType, if set) |
| workflowArchival.delayQueueWorkerThreadCount | string | `""` | Number of threads processing the delayed archivals |
| workflowArchival.delaySeconds | string | `""` | Delay in seconds before archiving a completed workflow (defaults to 60) |
| workflowArchival.enabled | bool | `false` | Enable workflow archival |
| workflowArchival.s3BucketName | string | `""` | S3 bucket name when type is S3 |
| workflowArchival.s3BucketRegion | string | `""` | S3 bucket region when type is S3 (defaults to us-east-1) |
| workflowArchival.ttl | string | `""` | Time to keep the completed workflows before removing them (e.g., 30d; if set, it takes precedence over type) |
| workflowArchival.type | string | `"DEFAULT"` | Archival type (DEFAULT keeps the workflows in the indexing backend only, S3 also uploads them to S3) |
| workflowArchival.unsuccessfulOnly | bool | `false` | Archive only the workflows that did not complete successfully |
| workflowExecutionLock | object | `{"type":"redis"}` | Workflow execution lock configuration |
| workflowExecutionLock.type | string | `"redis"` | Workflow execution lock type (redis, postgres, sqlite, local_only, noop_lock; postgres and sqlite require the same db.type) |
| workflowMessageQueue | object | `{"enabled":false,"maxBatchSize":100,"maxQueueSize":1000,"ttlSeconds":86400}` | Workflow message queue configuration |
| workflowMessageQueue.enabled | bool | `false` | Enable the workflow message queue |
| workflowMessageQueue.maxBatchSize | int | `100` | Maximum messages processed in a batch |
| workflowMessageQueue.maxQueueSize | int | `1000` | Maximum number of messages in the queue |
| workflowMessageQueue.ttlSeconds | int | `86400` | Message time-to-live in seconds |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
