import '../core/health_response.dart';
import '../core/http_client.dart';
import 'llm_hub_models.dart';

/// Client for the NodeDa Vertex LLM Hub API
/// (`https://api.nodeda.com` — path prefix `/v1/organizations/{orgId}/llm/`).
///
/// OpenAI-compatible chat completions. The **server** chooses the upstream
/// (Nrova Gemini vs BYO) from Developer → LLM Hub `routingMode`
/// (`nrova` | `byo` | `prefer_byo`). Clients keep the same request shape;
/// `model` is an optional hint. Requires a developer API key with the
/// [LLMHubScope.invoke] (`llm:invoke`) scope.
///
/// ```dart
/// // Prefer omitting model — Hub / BYO defaults apply.
/// final completion = await client.llmHub.chat(
///   messages: [
///     ChatMessage(role: ChatMessageRole.system, content: 'You are a helpful assistant.'),
///     ChatMessage(role: ChatMessageRole.user, content: 'Summarize our release notes.'),
///   ],
///   temperature: 0.2,
///   maxTokens: 512,
/// );
/// print(completion.firstContent);
/// ```
class LLMHubService {
  LLMHubService({required HttpClient http, required String orgId})
      : _http = http,
        _orgId = orgId;

  final HttpClient _http;
  final String _orgId;

  String _base() => 'v1/organizations/$_orgId/llm';

  /// `GET /health` — does not require an API key.
  Future<HealthResponse> health() => _http.get(
        'health',
        decode: (json) =>
            HealthResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
      );

  /// `POST …/llm/chat/completions` — requires `llm:invoke`.
  Future<ChatCompletionResponse> createChatCompletion(
    ChatCompletionRequest request,
  ) =>
      _http.post(
        '${_base()}/chat/completions',
        body: request.toJson(),
        decode: (json) => ChatCompletionResponse.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );

  /// Sugar for [createChatCompletion].
  Future<ChatCompletionResponse> chat({
    required List<ChatMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
  }) =>
      createChatCompletion(
        ChatCompletionRequest(
          messages: messages,
          model: model,
          temperature: temperature,
          maxTokens: maxTokens,
        ),
      );
}
