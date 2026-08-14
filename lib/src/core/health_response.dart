/// Response returned by every `GET /health` endpoint across NodeDa services.
class HealthResponse {
  const HealthResponse({required this.ok, this.service, this.schema});

  final bool ok;
  final String? service;
  final String? schema;

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      ok: json['ok'] as bool? ?? false,
      service: json['service'] as String?,
      schema: json['schema'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'ok': ok,
        if (service != null) 'service': service,
        if (schema != null) 'schema': schema,
      };
}
