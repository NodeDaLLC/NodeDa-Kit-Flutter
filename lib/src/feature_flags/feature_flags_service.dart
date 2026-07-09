import '../core/health_response.dart';
import '../core/http_client.dart';
import 'feature_flags_models.dart';

/// Client for the NodeDa Feature Flags / Developer API.
class FeatureFlagsService {
  FeatureFlagsService({required HttpClient http, required String orgId})
      : _http = http,
        _orgId = orgId;

  final HttpClient _http;
  final String _orgId;

  String _base() => 'v1/organizations/$_orgId';

  Future<HealthResponse> health() => _http.get(
        'health',
        decode: (json) =>
            HealthResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
      );

  Future<FeatureFlagsResponse> listFlags() => _http.get(
        '${_base()}/flags',
        decode: (json) => FeatureFlagsResponse.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );

  Future<EvaluateFlagsResponse> evaluate(EvaluateFlagsRequest request) =>
      _http.post(
        '${_base()}/evaluate',
        body: request.toJson(),
        decode: (json) => EvaluateFlagsResponse.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );

  /// Evaluates a single flag for [subjectId].
  Future<bool> isEnabled({
    required String flagKey,
    required String subjectId,
    String? countryCode,
  }) async {
    final response = await evaluate(
      EvaluateFlagsRequest(
        subjectId: subjectId,
        countryCode: countryCode,
        flagKeys: [flagKey],
      ),
    );
    return response.results[flagKey] ?? false;
  }
}
