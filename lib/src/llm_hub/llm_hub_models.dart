/// OpenAI-compatible chat message role for LLM Hub completions.
enum ChatMessageRole {
  system('system'),
  user('user'),
  assistant('assistant');

  const ChatMessageRole(this.wire);
  final String wire;

  static ChatMessageRole? fromWire(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wire == value) return e;
    }
    return null;
  }

  static ChatMessageRole parse(String value) =>
      fromWire(value) ?? (throw FormatException('Unknown role: $value'));
}

/// One turn in an OpenAI-style chat completions request.
class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  final ChatMessageRole role;
  final String content;

  Map<String, dynamic> toJson() => {
        'role': role.wire,
        'content': content,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: ChatMessageRole.parse(json['role'] as String),
      content: json['content'] as String,
    );
  }
}

/// Request body for `POST …/llm/chat/completions`.
///
/// Wire field names follow the OpenAI chat-completions shape (`max_tokens`, …).
class ChatCompletionRequest {
  const ChatCompletionRequest({
    required this.messages,
    this.model,
    this.temperature,
    this.maxTokens,
  });

  final List<ChatMessage> messages;
  final String? model;
  final double? temperature;
  final int? maxTokens;

  Map<String, dynamic> toJson() => {
        'messages': messages.map((m) => m.toJson()).toList(growable: false),
        if (model != null) 'model': model,
        if (temperature != null) 'temperature': temperature,
        if (maxTokens != null) 'max_tokens': maxTokens,
      };
}

/// Token usage reported by a chat completion response.
class ChatCompletionUsage {
  const ChatCompletionUsage({
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
  });

  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;

  factory ChatCompletionUsage.fromJson(Map<String, dynamic> json) {
    return ChatCompletionUsage(
      promptTokens: (json['prompt_tokens'] as num?)?.toInt(),
      completionTokens: (json['completion_tokens'] as num?)?.toInt(),
      totalTokens: (json['total_tokens'] as num?)?.toInt(),
    );
  }
}

/// Assistant message nested under a completion choice.
class ChatCompletionChoiceMessage {
  const ChatCompletionChoiceMessage({this.role, this.content});

  final ChatMessageRole? role;
  final String? content;

  factory ChatCompletionChoiceMessage.fromJson(Map<String, dynamic> json) {
    return ChatCompletionChoiceMessage(
      role: ChatMessageRole.fromWire(json['role'] as String?),
      content: json['content'] as String?,
    );
  }
}

/// One choice in an OpenAI-style chat completion response.
class ChatCompletionChoice {
  const ChatCompletionChoice({
    this.index,
    this.message,
    this.finishReason,
  });

  final int? index;
  final ChatCompletionChoiceMessage? message;
  final String? finishReason;

  factory ChatCompletionChoice.fromJson(Map<String, dynamic> json) {
    return ChatCompletionChoice(
      index: (json['index'] as num?)?.toInt(),
      message: json['message'] == null
          ? null
          : ChatCompletionChoiceMessage.fromJson(
              Map<String, dynamic>.from(json['message'] as Map),
            ),
      finishReason: json['finish_reason'] as String?,
    );
  }
}

/// Response body for `POST …/llm/chat/completions`.
class ChatCompletionResponse {
  const ChatCompletionResponse({
    this.id,
    this.objectType,
    this.created,
    this.model,
    this.choices = const [],
    this.usage,
  });

  final String? id;
  final String? objectType;
  final int? created;
  final String? model;
  final List<ChatCompletionChoice> choices;
  final ChatCompletionUsage? usage;

  /// Convenience: first choice’s assistant text, if present.
  String? get firstContent =>
      choices.isEmpty ? null : choices.first.message?.content;

  factory ChatCompletionResponse.fromJson(Map<String, dynamic> json) {
    return ChatCompletionResponse(
      id: json['id'] as String?,
      objectType: json['object'] as String?,
      created: (json['created'] as num?)?.toInt(),
      model: json['model'] as String?,
      choices: (json['choices'] as List<dynamic>? ?? const [])
          .map(
            (e) => ChatCompletionChoice.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(growable: false),
      usage: json['usage'] == null
          ? null
          : ChatCompletionUsage.fromJson(
              Map<String, dynamic>.from(json['usage'] as Map),
            ),
    );
  }
}

/// Catalog model ids for Nrova-routed Gemini models on LLM Hub.
///
/// Prefer these constants (or omit `model` to use the org default) over
/// hard-coding strings. BYO routing may accept additional provider ids
/// configured under Org Settings → Custom LLM.
abstract final class LLMHubModelID {
  /// Cost-efficient default for high-volume completions.
  static const String gemini31FlashLite = 'gemini-3.1-flash-lite';

  /// Balanced speed and quality for general production workloads.
  static const String gemini25Flash = 'gemini-2.5-flash';

  /// Strong reasoning and coding; elevated rates above 200k input tokens.
  static const String gemini25Pro = 'gemini-2.5-pro';

  /// Frontier Flash-class model (preview).
  static const String gemini3FlashPreview = 'gemini-3-flash-preview';

  /// Highest Flash intelligence with search and grounding strength.
  static const String gemini35Flash = 'gemini-3.5-flash';

  /// Recommended default when the org has no configured default yet.
  static const String recommendedDefault = gemini31FlashLite;
}

/// Scope required on Developer API keys to call LLM Hub inference.
abstract final class LLMHubScope {
  static const String invoke = 'llm:invoke';
}
