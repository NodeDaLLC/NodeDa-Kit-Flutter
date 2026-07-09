/// Lossless representation of arbitrary JSON for free-form API fields.
sealed class JsonValue {
  const JsonValue();

  /// Underlying Dart value (`bool`, `int`, `double`, `String`, `List`, `Map`, or `null`).
  Object? get rawValue;

  static JsonValue fromAny(Object? any) {
    if (any == null) return const JsonNull();
    if (any is bool) return JsonBool(any);
    if (any is int) return JsonInt(any);
    if (any is double) return JsonNumber(any);
    if (any is String) return JsonText(any);
    if (any is List) {
      return JsonArray(any.map(fromAny).toList(growable: false));
    }
    if (any is Map) {
      return JsonObject({
        for (final entry in any.entries)
          entry.key.toString(): fromAny(entry.value),
      });
    }
    return JsonText(any.toString());
  }

  static JsonValue fromJson(Object? json) => fromAny(json);

  Object? toJson();
}

final class JsonNull extends JsonValue {
  const JsonNull();

  @override
  Object? get rawValue => null;

  @override
  Object? toJson() => null;
}

final class JsonBool extends JsonValue {
  const JsonBool(this.value);
  final bool value;

  @override
  Object? get rawValue => value;

  @override
  Object? toJson() => value;
}

final class JsonInt extends JsonValue {
  const JsonInt(this.value);
  final int value;

  @override
  Object? get rawValue => value;

  @override
  Object? toJson() => value;
}

final class JsonNumber extends JsonValue {
  const JsonNumber(this.value);
  final double value;

  @override
  Object? get rawValue => value;

  @override
  Object? toJson() => value;
}

final class JsonText extends JsonValue {
  const JsonText(this.value);
  final String value;

  @override
  Object? get rawValue => value;

  @override
  Object? toJson() => value;
}

final class JsonArray extends JsonValue {
  const JsonArray(this.values);
  final List<JsonValue> values;

  @override
  Object? get rawValue => values.map((v) => v.rawValue).toList(growable: false);

  @override
  Object? toJson() => values.map((v) => v.toJson()).toList(growable: false);
}

final class JsonObject extends JsonValue {
  const JsonObject(this.values);
  final Map<String, JsonValue> values;

  @override
  Object? get rawValue =>
      values.map((key, value) => MapEntry(key, value.rawValue));

  @override
  Object? toJson() =>
      values.map((key, value) => MapEntry(key, value.toJson()));
}

Map<String, JsonValue>? jsonValueMapFromJson(Object? json) {
  if (json == null) return null;
  if (json is! Map) return null;
  return {
    for (final entry in json.entries)
      entry.key.toString(): JsonValue.fromJson(entry.value),
  };
}

Map<String, Object?>? jsonValueMapToJson(Map<String, JsonValue>? map) {
  if (map == null) return null;
  return map.map((key, value) => MapEntry(key, value.toJson()));
}
