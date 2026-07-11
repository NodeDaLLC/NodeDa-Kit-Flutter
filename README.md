# NodeDa Flutter

**Current version: `1.2.0`** · available at runtime as `NodeDa.version`.

The official Flutter/Dart SDK for the **NodeDa** HTTP APIs. One typed
client, one auth scheme, every public service NodeDa exposes — built on
Dart `Future`s and `package:http`. Mirrors the
[NodeDa Android](https://github.com/NodeDaLLC/NodeDa-Kit-Android) and Swift
SDKs for API parity across platforms.

```dart
import 'package:nodeda/nodeda.dart';

final client = NodeDaClient(apiKey: 'sk_live_…');

final latest = await client.distribution.latest(
  appId: 'acme-notes',
  platform: DistributionPlatform.macos,
  channel: DistributionChannel.stable,
);
print('Latest version: ${latest.artifact.version ?? latest.release.version}');
print('SDK version: ${NodeDa.version}'); // "1.2.0"
```

## Requirements

| Tooling | Minimum |
| ------- | ------- |
| Dart SDK | 3.9+ |
| Flutter | 3.24+ (optional — this is a pure Dart package) |

No platform channels or native plugins — works on Flutter mobile, desktop,
web, and plain Dart VMs.

## Installation

Add the package as a Git dependency in your app's `pubspec.yaml`:

```yaml
dependencies:
  nodeda:
    git:
      url: https://github.com/NodeDaLLC/NodeDa-Kit-Flutter.git
      ref: main
```

Then fetch packages:

```bash
flutter pub get
# or: dart pub get
```

Import and use:

```dart
import 'package:nodeda/nodeda.dart';
```

To pin a release, set `ref` to a tag (e.g. `v1.2.0`) once tags are published.

## Authentication

Every authenticated request sends **both**:

- `Authorization: Bearer <apiKey>`
- `X-API-Key: <apiKey>`

`GET /health` and the public applications feed are unauthenticated.

### From an API key

```dart
final client = NodeDaClient(
  apiKey: 'sk_live_…',
  organizationId: 'your-org-id', // optional; defaults to the SDK default
);
```

### From a map (Flutter analog of AndroidManifest / Info.plist)

```dart
final client = NodeDaClient.fromMap({
  'com.nodeda.sdk.ApiKey': const String.fromEnvironment('NODEDA_API_KEY'),
  'com.nodeda.sdk.OrganizationId': const String.fromEnvironment('NODEDA_ORG_ID'),
});
```

Run with:

```bash
flutter run --dart-define=NODEDA_API_KEY=sk_live_… --dart-define=NODEDA_ORG_ID=…
```

## Services

| Property | API |
| -------- | --- |
| `client.distribution` | Releases / downloads |
| `client.support` | Support tickets |
| `client.sales` | Sales submissions |
| `client.careers` | Jobs / applications |
| `client.newsroom` | News posts |
| `client.featureFlags` | Feature flags / evaluate |
| `client.systemStatus` | Status page |
| `client.legal` | Legal policies |
| `client.llmHub` | LLM Hub chat completions |

```dart
// Parallel health check across all nine services
final health = await client.healthAll();
```

All traffic uses the unified gateway `https://api.nodeda.com`.

### LLM Hub API

OpenAI-compatible chat completions via the Vertex LLM Hub gateway
(`https://api.nodeda.com`). Requires a developer API key with the
`llm:invoke` scope (`LLMHubScope.invoke`).

**Server-owned routing:** the gateway picks Nrova Gemini vs BYO from
Developer → LLM Hub **Routing** (`nrova` | `byo` | `prefer_byo`). Clients
do not send a provider URL, API key, or routing mode. `model` is an
optional hint — omit it for the org default (Nrova) or the Custom LLM
configured model (BYO). Catalog ids for Nrova live on `LLMHubModelID`.

| Method | Endpoint | Scope |
| --- | --- | --- |
| `llmHub.health()` | `GET /health` | none |
| `llmHub.createChatCompletion(request)` | `POST …/llm/chat/completions` | `llm:invoke` |
| `llmHub.chat(messages:, model:, temperature:, maxTokens:)` | `POST …/llm/chat/completions` | `llm:invoke` |

Prefer omitting `model` so Hub defaults apply:

```dart
final completion = await client.llmHub.chat(
  messages: [
    ChatMessage(role: ChatMessageRole.system, content: 'You are a helpful assistant.'),
    ChatMessage(role: ChatMessageRole.user, content: 'Summarize our release notes.'),
  ],
  temperature: 0.2,
  maxTokens: 512,
);
print(completion.firstContent);
```

Or pass a catalog id when you need a specific Nrova model:

```dart
final completion = await client.llmHub.createChatCompletion(
  ChatCompletionRequest(
    messages: [
      ChatMessage(role: ChatMessageRole.system, content: 'You are a helpful assistant.'),
      ChatMessage(role: ChatMessageRole.user, content: 'Summarize our release notes.'),
    ],
    model: LLMHubModelID.gemini31FlashLite,
    temperature: 0.2,
    maxTokens: 512,
  ),
);
print(completion.firstContent);

// Sugar with explicit model:
final reply = await client.llmHub.chat(
  messages: [ChatMessage(role: ChatMessageRole.user, content: 'Hello')],
  model: LLMHubModelID.recommendedDefault,
);
```

Gateway error codes (via `NodeDaApiException`): `hub_disabled`,
`model_not_found`, `byo_not_configured`, `byo_not_ready`,
`byo_model_missing`, `spend_cap_reached`, `upstream_unavailable`,
`upstream_error`, `upstream_timeout`, `insufficient_scope`.

#### Catalog model ids (`LLMHubModelID`)

| Constant | Wire id | Notes |
| --- | --- | --- |
| `gemini31FlashLite` | `gemini-3.1-flash-lite` | Recommended default (`recommendedDefault`) |
| `gemini25Flash` | `gemini-2.5-flash` | Balanced production Flash |
| `gemini25Pro` | `gemini-2.5-pro` | Stronger reasoning; elevated rates above 200k input |
| `gemini3FlashPreview` | `gemini-3-flash-preview` | Frontier Flash preview |
| `gemini35Flash` | `gemini-3.5-flash` | Highest Flash-class intelligence |

#### Request / response

Request encodes `maxTokens` as wire `max_tokens`. Nil optionals are
**omitted** from the JSON body. Response fields use snake_case on the wire
and camelCase in Dart (`promptTokens`, `finishReason`). Prefer
`ChatCompletionResponse.firstContent` for the assistant string.

v1 does **not** include streaming, tools/function calling, or multimodal
content arrays — text chat completions only.

## Error handling

```dart
try {
  await client.distribution.listApplications();
} on NodeDaApiException catch (e) {
  print('${e.error.status} ${e.error.code}: ${e.error.message}');
} on NodeDaTransportException catch (e) {
  print('Network: $e');
} on NodeDaDecodingException catch (e) {
  print('Decode: $e');
}
```

## Custom transports & testing

Inject a [NodeDaTransport] to stub HTTP in unit tests:

```dart
class MockTransport implements NodeDaTransport {
  @override
  Future<NodeDaResponse> send(NodeDaRequest request) async {
    // assert on request.url / headers, return canned bytes
  }
}

final client = NodeDaClient(apiKey: 'test', transport: MockTransport());
```

## Project layout

```text
lib/
  nodeda.dart                 # barrel export
  src/
    node_da_client.dart       # facade
    core/                     # config, HTTP, errors, JsonValue
    distribution/
    support/
    sales/
    careers/
    newsroom/
    feature_flags/
    system_status/
    legal/
    llm_hub/
```

## License

MIT
