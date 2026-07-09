import '../core/health_response.dart';
import '../core/http_client.dart';
import 'sales_models.dart';

/// Client for the NodeDa Sales API.
class SalesService {
  SalesService({required HttpClient http, required String orgId})
      : _http = http,
        _orgId = orgId;

  final HttpClient _http;
  final String _orgId;

  String _base() => 'v1/organizations/$_orgId/sales';

  Future<HealthResponse> health() => _http.get(
        'health',
        decode: (json) =>
            HealthResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
      );

  Future<SalesSubmission> createSubmission(
    CreateSalesSubmissionRequest request,
  ) async {
    final envelope = await _http.post(
      '${_base()}/submissions',
      body: request.toJson(),
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return SalesSubmission.fromJson(
      Map<String, dynamic>.from(envelope['submission'] as Map),
    );
  }

  Future<List<SalesSubmission>> listSubmissions(
    String contactEmail, {
    int? limit,
  }) async {
    final envelope = await _http.get(
      '${_base()}/submissions',
      decode: (json) => Map<String, dynamic>.from(json as Map),
      query: {
        'contactEmail': contactEmail,
        'limit': limit?.toString(),
      },
    );
    return (envelope['submissions'] as List<dynamic>? ?? const [])
        .map(
          (e) =>
              SalesSubmission.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(growable: false);
  }

  Future<SalesSubmission> getSubmission(String submissionId) async {
    final envelope = await _http.get(
      '${_base()}/submissions/$submissionId',
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return SalesSubmission.fromJson(
      Map<String, dynamic>.from(envelope['submission'] as Map),
    );
  }

  Future<List<SalesComment>> listComments(String submissionId) async {
    final envelope = await _http.get(
      '${_base()}/submissions/$submissionId/comments',
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return (envelope['comments'] as List<dynamic>? ?? const [])
        .map((e) => SalesComment.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
  }

  Future<SalesComment> addComment(
    String submissionId,
    CreateSalesCommentRequest request,
  ) async {
    final envelope = await _http.post(
      '${_base()}/submissions/$submissionId/comments',
      body: request.toJson(),
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return SalesComment.fromJson(
      Map<String, dynamic>.from(envelope['comment'] as Map),
    );
  }
}
