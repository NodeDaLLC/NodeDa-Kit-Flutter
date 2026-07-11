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
(Nrova Gemini + optional BYO routing). Requires a developer API key with
the `llm:invoke` scope (`LLMHubScope.invoke`). Omit `model` to use the
org’s configured default; catalog ids live on `LLMHubModelID`.

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

// Sugar:
final reply = await client.llmHub.chat(
  messages: [ChatMessage(role: ChatMessageRole.user, content: 'Hello')],
  model: LLMHubModelID.recommendedDefault,
);
```

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
