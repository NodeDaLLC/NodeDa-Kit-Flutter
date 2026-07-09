import 'dart:convert';

import 'json_value.dart';
import 'node_da_configuration.dart';
import 'node_da_error.dart';
import 'node_da_transport.dart';

/// Shared body encoding helper.
List<int> _utf8Bytes(String text) => utf8.encode(text);

/// Internal HTTP plumbing shared by every service client.
class HttpClient {
  HttpClient({
    required this.baseUrl,
    required this.configuration,
    required this.transport,
    this.requiresAuth = true,
  });

  final String baseUrl;
  final NodeDaConfiguration configuration;
  final NodeDaTransport transport;
  final bool requiresAuth;

  Future<T> get<T>(
    String path, {
    required T Function(Object? json) decode,
    Map<String, String?> query = const {},
    bool authenticated = true,
  }) async {
    final request = _buildRequest(
      method: 'GET',
      path: path,
      query: query,
      body: null,
      authenticated: authenticated,
    );
    return _perform(request, decode);
  }

  Future<T> post<T>(
    String path, {
    required Object? body,
    required T Function(Object? json) decode,
    Map<String, String?> query = const {},
    bool authenticated = true,
  }) async {
    final request = _buildRequest(
      method: 'POST',
      path: path,
      query: query,
      body: body == null ? null : jsonEncode(_stripNulls(body)),
      authenticated: authenticated,
    );
    return _perform(request, decode);
  }

  Future<T> patch<T>(
    String path, {
    required Object? body,
    required T Function(Object? json) decode,
    Map<String, String?> query = const {},
    bool authenticated = true,
  }) async {
    final request = _buildRequest(
      method: 'PATCH',
      path: path,
      query: query,
      body: body == null ? null : jsonEncode(_stripNulls(body)),
      authenticated: authenticated,
    );
    return _perform(request, decode);
  }

  Future<T> put<T>(
    String path, {
    required Object? body,
    required T Function(Object? json) decode,
    Map<String, String?> query = const {},
    bool authenticated = true,
  }) async {
    final request = _buildRequest(
      method: 'PUT',
      path: path,
      query: query,
      body: body == null ? null : jsonEncode(_stripNulls(body)),
      authenticated: authenticated,
    );
    return _perform(request, decode);
  }

  Future<void> delete(
    String path, {
    Map<String, String?> query = const {},
    bool authenticated = true,
  }) async {
    final request = _buildRequest(
      method: 'DELETE',
      path: path,
      query: query,
      body: null,
      authenticated: authenticated,
    );
    final response = await _sendThrowing(request);
    _validate(response);
  }

  /// Returns the raw response — useful for 302 endpoints where we need the
  /// `Location` header. Does not follow redirects.
  Future<NodeDaResponse> head(
    String path, {
    Map<String, String?> query = const {},
    bool authenticated = true,
  }) async {
    final request = _buildRequest(
      method: 'GET',
      path: path,
      query: query,
      body: null,
      authenticated: authenticated,
      followRedirects: false,
    );
    return _sendThrowing(request);
  }

  NodeDaRequest _buildRequest({
    required String method,
    required String path,
    required Map<String, String?> query,
    required String? body,
    required bool authenticated,
    bool followRedirects = true,
  }) {
    final base = Uri.parse(baseUrl);
    final segments = path
        .split('/')
        .where((s) => s.isNotEmpty)
        .map(Uri.encodeComponent)
        .toList();
    final filteredQuery = <String, String>{
      for (final entry in query.entries)
        if (entry.value != null) entry.key: entry.value!,
    };

    final url = base.replace(
      pathSegments: [
        ...base.pathSegments.where((s) => s.isNotEmpty),
        ...segments,
      ],
      queryParameters: filteredQuery.isEmpty ? null : filteredQuery,
    );

    final headers = <String, String>{
      'Accept': 'application/json',
      ...configuration.defaultHeaders,
    };
    if (body != null) {
      headers['Content-Type'] = 'application/json';
    }
    if (authenticated && requiresAuth && configuration.apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${configuration.apiKey}';
      headers['X-API-Key'] = configuration.apiKey;
    }

    return NodeDaRequest(
      method: method,
      url: url,
      headers: headers,
      body: body == null ? null : _utf8Bytes(body),
      followRedirects: followRedirects,
    );
  }

  Future<NodeDaResponse> _sendThrowing(NodeDaRequest request) async {
    try {
      return await transport.send(request).timeout(configuration.timeout);
    } on NodeDaException {
      rethrow;
    } catch (e) {
      throw NodeDaTransportException(e);
    }
  }

  Future<T> _perform<T>(
    NodeDaRequest request,
    T Function(Object? json) decode,
  ) async {
    final response = await _sendThrowing(request);
    _validate(response);
    return _decodeBody(response.bodyBytes, decode);
  }

  T _decodeBody<T>(List<int> bytes, T Function(Object? json) decode) {
    if (identical(decode, _unitDecode)) {
      return null as T;
    }
    try {
      if (bytes.isEmpty) {
        return decode(null);
      }
      final text = utf8.decode(bytes);
      final Object? json = jsonDecode(text);
      return decode(json);
    } catch (e) {
      throw NodeDaDecodingException(e, bytes);
    }
  }

  void _validate(NodeDaResponse response, [List<int>? bytes]) {
    if (response.isSuccessful) return;
    final payload = bytes ?? response.bodyBytes;
    final apiError = _decodeApiError(response.statusCode, payload);
    if (apiError != null) throw NodeDaApiException(apiError);
    throw NodeDaUnexpectedStatusException(response.statusCode, payload);
  }

  NodeDaApiError? _decodeApiError(int status, List<int> data) {
    if (data.isEmpty) return null;
    try {
      final decoded = jsonDecode(utf8.decode(data));
      if (decoded is! Map) return null;
      final code = (decoded['error'] as String?) ??
          (decoded['code'] as String?) ??
          'unknown_error';
      final message = decoded['message'] as String?;
      final details = jsonValueMapFromJson(decoded['details']);
      return NodeDaApiError(
        status: status,
        code: code,
        message: message,
        details: details,
      );
    } catch (_) {
      return null;
    }
  }

  /// Recursively omit nulls so outgoing JSON matches Kotlin/Swift behavior.
  static Object? _stripNulls(Object? value) {
    if (value == null) return null;
    if (value is Map) {
      final out = <String, Object?>{};
      value.forEach((key, v) {
        final stripped = _stripNulls(v);
        if (stripped != null) out[key.toString()] = stripped;
      });
      return out;
    }
    if (value is List) {
      return value.map(_stripNulls).where((e) => e != null).toList();
    }
    if (value is JsonValue) return _stripNulls(value.toJson());
    return value;
  }
}

/// Sentinel decode used for empty DELETE-style responses when needed.
Object? _unitDecode(Object? _) => null;
