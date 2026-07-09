import '../core/health_response.dart';
import '../core/http_client.dart';
import 'legal_models.dart';

/// Client for the NodeDa Legal Policies API.
class LegalService {
  LegalService({required HttpClient http, required String orgId})
      : _http = http,
        _orgId = orgId;

  final HttpClient _http;
  final String _orgId;

  String _base() => 'v1/organizations/$_orgId/legal-policies';

  Future<HealthResponse> health() => _http.get(
        'health',
        decode: (json) =>
            HealthResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
      );

  Future<LegalPoliciesResponse> listPolicies() => _http.get(
        _base(),
        decode: (json) => LegalPoliciesResponse.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );

  Future<LegalPolicyResponse> getPolicyByKey(String key) => _http.get(
        '${_base()}/by-key/$key',
        decode: (json) => LegalPolicyResponse.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );

  Future<LegalPolicyResponse> getPolicyById(String policyId) => _http.get(
        '${_base()}/$policyId',
        decode: (json) => LegalPolicyResponse.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );

  Future<LegalPolicyResponse> createPolicy(CreateLegalPolicyRequest request) =>
      _http.post(
        _base(),
        body: request.toJson(),
        decode: (json) => LegalPolicyResponse.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );

  Future<LegalPolicyResponse> updatePolicy(
    String policyId,
    UpdateLegalPolicyRequest update,
  ) =>
      _http.put(
        '${_base()}/$policyId',
        body: update.toJson(),
        decode: (json) => LegalPolicyResponse.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );

  Future<void> deletePolicy(String policyId) =>
      _http.delete('${_base()}/$policyId');

  Future<LegalPolicySection> createSection(
    String policyId,
    CreateLegalSectionRequest request,
  ) async {
    final envelope = await _http.post(
      '${_base()}/$policyId/sections',
      body: request.toJson(),
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return LegalPolicySection.fromJson(
      Map<String, dynamic>.from(envelope['section'] as Map),
    );
  }

  Future<LegalPolicySection> updateSection(
    String policyId,
    String sectionId,
    UpdateLegalSectionRequest update,
  ) async {
    final envelope = await _http.put(
      '${_base()}/$policyId/sections/$sectionId',
      body: update.toJson(),
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return LegalPolicySection.fromJson(
      Map<String, dynamic>.from(envelope['section'] as Map),
    );
  }

  Future<void> deleteSection(String policyId, String sectionId) =>
      _http.delete('${_base()}/$policyId/sections/$sectionId');
}
