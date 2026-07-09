import 'service_endpoints.dart';

/// Static configuration for talking to the public NodeDa HTTP APIs.
class NodeDaConfiguration {
  NodeDaConfiguration({
    required this.apiKey,
    this.organizationId = defaultOrganizationId,
    ServiceEndpoints? endpoints,
    this.defaultHeaders = const {},
    this.timeout = const Duration(seconds: 30),
  }) : endpoints = endpoints ?? ServiceEndpoints.production;

  /// Default organization id used when none is supplied.
  ///
  /// Production apps should still pass an explicit [organizationId] so the
  /// correct tenant is always explicit at ship time.
  static const String defaultOrganizationId = 'C1IRXJbknvZSTKMBxLDQ';

  /// API key used as `Authorization: Bearer <key>` and `X-API-Key`.
  final String apiKey;

  /// Organization id used in the URL path (`/v1/organizations/{orgId}/...`).
  final String organizationId;

  /// Service base URLs. Override to point at a staging environment or proxy.
  final ServiceEndpoints endpoints;

  /// Extra headers sent with every request (e.g. tracing / telemetry).
  final Map<String, String> defaultHeaders;

  /// Per-request timeout. Defaults to 30 seconds.
  final Duration timeout;
}
