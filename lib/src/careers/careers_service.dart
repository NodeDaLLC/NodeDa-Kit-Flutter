import '../core/health_response.dart';
import '../core/http_client.dart';
import 'careers_models.dart';

/// Client for the NodeDa Careers API.
class CareersService {
  CareersService({required HttpClient http, required String orgId})
      : _http = http,
        _orgId = orgId;

  final HttpClient _http;
  final String _orgId;

  String _base() => 'v1/organizations/$_orgId/careers';

  Future<HealthResponse> health() => _http.get(
        'health',
        decode: (json) =>
            HealthResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
      );

  Future<List<CareerPosting>> listPostings() async {
    final envelope = await _http.get(
      '${_base()}/postings',
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return (envelope['postings'] as List<dynamic>? ?? const [])
        .map((e) => CareerPosting.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
  }

  Future<CareerPosting> getPosting(String requisitionNodeId) async {
    final envelope = await _http.get(
      '${_base()}/postings/$requisitionNodeId',
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return CareerPosting.fromJson(
      Map<String, dynamic>.from(envelope['posting'] as Map),
    );
  }

  Future<CareerApplicationTemplate> applicationTemplate() async {
    final envelope = await _http.get(
      '${_base()}/application-template',
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return CareerApplicationTemplate.fromJson(
      Map<String, dynamic>.from(envelope['template'] as Map),
    );
  }

  Future<List<CareerApplication>> listApplications({
    String? applicantEmail,
    String? contactEmail,
    String? status,
    int? limit,
  }) async {
    final envelope = await _http.get(
      '${_base()}/applications',
      decode: (json) => Map<String, dynamic>.from(json as Map),
      query: {
        'applicantEmail': applicantEmail,
        'contactEmail': contactEmail,
        'status': status,
        'limit': limit?.toString(),
      },
    );
    return (envelope['applications'] as List<dynamic>? ?? const [])
        .map(
          (e) =>
              CareerApplication.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(growable: false);
  }

  Future<CareerApplication> getApplication(String applicationId) async {
    final envelope = await _http.get(
      '${_base()}/applications/$applicationId',
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return CareerApplication.fromJson(
      Map<String, dynamic>.from(envelope['application'] as Map),
    );
  }

  Future<CareerApplication> submitApplication(
    SubmitCareerApplicationRequest request,
  ) async {
    final envelope = await _http.post(
      '${_base()}/applications',
      body: request.toJson(),
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return CareerApplication.fromJson(
      Map<String, dynamic>.from(envelope['application'] as Map),
    );
  }
}
