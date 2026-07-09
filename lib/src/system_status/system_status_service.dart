import '../core/health_response.dart';
import '../core/http_client.dart';
import 'system_status_models.dart';

/// Client for the NodeDa System Status API.
class SystemStatusService {
  SystemStatusService({required HttpClient http, required String orgId})
      : _http = http,
        _orgId = orgId;

  final HttpClient _http;
  final String _orgId;

  String _base() => 'v1/organizations/$_orgId/status';

  Future<HealthResponse> health() => _http.get(
        'health',
        decode: (json) =>
            HealthResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
      );

  Future<SystemStatusRollup> rollup() => _http.get(
        _base(),
        decode: (json) => SystemStatusRollup.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );

  Future<SystemStatusComponent> getComponent(String componentId) async {
    final envelope = await _http.get(
      '${_base()}/components/$componentId',
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return SystemStatusComponent.fromJson(
      Map<String, dynamic>.from(envelope['component'] as Map),
    );
  }

  Future<SystemStatusComponent> createComponent(
    CreateStatusComponentRequest request,
  ) async {
    final envelope = await _http.post(
      '${_base()}/components',
      body: request.toJson(),
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return SystemStatusComponent.fromJson(
      Map<String, dynamic>.from(envelope['component'] as Map),
    );
  }

  Future<SystemStatusComponent> updateComponent(
    String componentId,
    UpdateStatusComponentRequest update,
  ) async {
    final envelope = await _http.put(
      '${_base()}/components/$componentId',
      body: update.toJson(),
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return SystemStatusComponent.fromJson(
      Map<String, dynamic>.from(envelope['component'] as Map),
    );
  }

  Future<void> deleteComponent(String componentId) =>
      _http.delete('${_base()}/components/$componentId');
}
