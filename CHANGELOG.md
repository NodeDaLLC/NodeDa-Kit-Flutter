## 1.4.0

- Added Drive HTTP API client (`client.drive`) for `nrova.drive.v1`.
- Paths are `/v1/drive/…` (not `/v1/organizations/{orgId}/…`). Auth is a
  Firebase ID token; Drive does not use `OrganizationId` or a developer
  API key.
- Included `drive` in `ServiceEndpoints` and `healthAll()`.

## 1.3.0

- Added Vertex App Analytics ingest client (`client.appAnalytics`) for
  `nrova.app-analytics.v1` (`POST …/app-analytics/events`).
- Typed platforms, SDKs, event factories, opaque install/session ids, and
  scope constant `AppAnalyticsScope.write`.
- Included `appAnalytics` in `ServiceEndpoints` and `healthAll()`.

## 1.2.1

- LLM Hub: document **server-owned routing** (`nrova` / `byo` / `prefer_byo` from Hub config). Clients do not pick the provider.
- Docs: prefer omitting `model`; list gateway error slugs for Hub / BYO / spend-cap failures.
- Nil `model` / temperature / maxTokens remain omitted from `toJson()`.

## 1.2.0

- Added Vertex LLM Hub client (`client.llmHub`) with OpenAI-compatible
  chat completions (`createChatCompletion` / `chat`).
- Catalog model ids on `LLMHubModelID`; scope constant `LLMHubScope.invoke`.
- Included `llmHub` in `ServiceEndpoints` and `healthAll()`.

## 1.1.0

- Initial Flutter/Dart port of the NodeDa Android SDK (`nodeda-android` 1.1).
- Typed clients for Distribution, Support, Sales, Careers, Newsroom, Feature Flags, System Status, and Legal.
- Dual auth headers, pluggable `NodeDaTransport`, and `NodeDaClient.healthAll()`.
