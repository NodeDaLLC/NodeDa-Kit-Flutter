import '../core/health_response.dart';
import '../core/http_client.dart';
import 'support_models.dart';

/// Client for the NodeDa Support API.
class SupportService {
  SupportService({required HttpClient http, required String orgId})
      : _http = http,
        _orgId = orgId;

  final HttpClient _http;
  final String _orgId;

  String _base() => 'v1/organizations/$_orgId/support';

  Future<HealthResponse> health() => _http.get(
        'health',
        decode: (json) =>
            HealthResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
      );

  Future<SupportTicket> createTicket(CreateSupportTicketRequest request) async {
    final envelope = await _http.post(
      '${_base()}/tickets',
      body: request.toJson(),
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return SupportTicket.fromJson(
      Map<String, dynamic>.from(envelope['ticket'] as Map),
    );
  }

  Future<List<SupportTicket>> listTickets(String contactEmail) async {
    final envelope = await _http.get(
      '${_base()}/tickets',
      decode: (json) => Map<String, dynamic>.from(json as Map),
      query: {'contactEmail': contactEmail},
    );
    return (envelope['tickets'] as List<dynamic>? ?? const [])
        .map((e) => SupportTicket.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
  }

  Future<SupportTicket> getTicket(String ticketId) async {
    final envelope = await _http.get(
      '${_base()}/tickets/$ticketId',
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return SupportTicket.fromJson(
      Map<String, dynamic>.from(envelope['ticket'] as Map),
    );
  }

  Future<List<SupportComment>> listComments(String ticketId) async {
    final envelope = await _http.get(
      '${_base()}/tickets/$ticketId/comments',
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return (envelope['comments'] as List<dynamic>? ?? const [])
        .map(
          (e) => SupportComment.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(growable: false);
  }

  Future<SupportComment> addComment(
    String ticketId,
    CreateSupportCommentRequest request,
  ) async {
    final envelope = await _http.post(
      '${_base()}/tickets/$ticketId/comments',
      body: request.toJson(),
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return SupportComment.fromJson(
      Map<String, dynamic>.from(envelope['comment'] as Map),
    );
  }
}
