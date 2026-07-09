import 'json_value.dart';

/// Errors surfaced by the NodeDa SDK.
sealed class NodeDaException implements Exception {
  const NodeDaException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Request URL could not be constructed.
final class NodeDaInvalidUrlException extends NodeDaException {
  NodeDaInvalidUrlException(this.raw)
      : super('Could not build a valid URL from $raw.');
  final String raw;
}

/// The underlying HTTP/network transport threw.
final class NodeDaTransportException extends NodeDaException {
  NodeDaTransportException(this.cause)
      : super('Network error: ${cause.toString()}');
  final Object cause;
}

/// The server returned a non-success status with a structured payload.
final class NodeDaApiException extends NodeDaException {
  NodeDaApiException(this.error)
      : super(
          '[${error.status} ${error.code}]'
          '${error.message != null && error.message!.isNotEmpty ? ' ${error.message}' : ''}',
        );
  final NodeDaApiError error;
}

/// JSON decoding of a successful response failed.
final class NodeDaDecodingException extends NodeDaException {
  NodeDaDecodingException(this.cause, [this.data])
      : super('Failed to decode NodeDa response: ${cause.toString()}');
  final Object cause;
  final List<int>? data;
}

/// The server returned an HTTP status code we don't know how to interpret.
final class NodeDaUnexpectedStatusException extends NodeDaException {
  NodeDaUnexpectedStatusException(this.status, [this.data])
      : super('Unexpected HTTP status $status.');
  final int status;
  final List<int>? data;
}

/// Structured payload returned by NodeDa Cloud Functions on failure.
class NodeDaApiError {
  const NodeDaApiError({
    required this.status,
    required this.code,
    this.message,
    this.details,
  });

  final int status;
  final String code;
  final String? message;
  final Map<String, JsonValue>? details;
}
