import 'dart:typed_data';

/// Minimal HTTP request used by [NodeDaTransport].
class NodeDaRequest {
  const NodeDaRequest({
    required this.method,
    required this.url,
    this.headers = const {},
    this.body,
    this.followRedirects = true,
  });

  final String method;
  final Uri url;
  final Map<String, String> headers;
  final List<int>? body;

  /// When `false`, 3xx responses are returned as-is (needed for `Location`).
  final bool followRedirects;
}

/// Minimal HTTP response returned by [NodeDaTransport].
class NodeDaResponse {
  const NodeDaResponse({
    required this.statusCode,
    required this.headers,
    required this.bodyBytes,
    this.request,
  });

  final int statusCode;
  final Map<String, String> headers;
  final Uint8List bodyBytes;
  final NodeDaRequest? request;

  bool get isSuccessful => statusCode >= 200 && statusCode < 300;

  String? header(String name) {
    final lower = name.toLowerCase();
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == lower) return entry.value;
    }
    return null;
  }
}

/// Minimal interface the SDK uses to perform HTTP requests.
///
/// Substitute a custom implementation in tests to replay canned responses.
abstract class NodeDaTransport {
  Future<NodeDaResponse> send(NodeDaRequest request);
}
