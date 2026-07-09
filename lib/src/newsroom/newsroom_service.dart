import '../core/health_response.dart';
import '../core/http_client.dart';
import 'newsroom_models.dart';

/// Client for the NodeDa Newsroom API.
class NewsroomService {
  NewsroomService({required HttpClient http, required String orgId})
      : _http = http,
        _orgId = orgId;

  final HttpClient _http;
  final String _orgId;

  String _base() => 'v1/organizations/$_orgId/newsroom';

  Future<HealthResponse> health() => _http.get(
        'health',
        decode: (json) =>
            HealthResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
      );

  Future<List<NewsroomCategory>> listCategories() async {
    final envelope = await _http.get(
      '${_base()}/categories',
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return (envelope['categories'] as List<dynamic>? ?? const [])
        .map(
          (e) =>
              NewsroomCategory.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(growable: false);
  }

  Future<List<NewsroomPost>> listPosts({
    NewsroomStatus? status,
    String? categoryId,
    String? tag,
    int? limit,
    bool includeDocument = false,
  }) async {
    final envelope = await _http.get(
      '${_base()}/posts',
      decode: (json) => Map<String, dynamic>.from(json as Map),
      query: {
        'status': status?.wire,
        'categoryId': categoryId,
        'tag': tag,
        'limit': limit?.toString(),
        'include': includeDocument ? 'document' : null,
      },
    );
    return (envelope['posts'] as List<dynamic>? ?? const [])
        .map((e) => NewsroomPost.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
  }

  Future<NewsroomPost> getPost(
    String idOrSlug, {
    bool includeDocument = false,
  }) async {
    final envelope = await _http.get(
      '${_base()}/posts/$idOrSlug',
      decode: (json) => Map<String, dynamic>.from(json as Map),
      query: {'include': includeDocument ? 'document' : null},
    );
    return NewsroomPost.fromJson(
      Map<String, dynamic>.from(envelope['post'] as Map),
    );
  }

  Future<NewsroomPost> createPost(CreateNewsroomPostRequest request) async {
    final envelope = await _http.post(
      '${_base()}/posts',
      body: request.toJson(),
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return NewsroomPost.fromJson(
      Map<String, dynamic>.from(envelope['post'] as Map),
    );
  }

  Future<NewsroomPost> updatePost(
    String postId,
    UpdateNewsroomPostRequest update,
  ) async {
    final envelope = await _http.patch(
      '${_base()}/posts/$postId',
      body: update.toJson(),
      decode: (json) => Map<String, dynamic>.from(json as Map),
    );
    return NewsroomPost.fromJson(
      Map<String, dynamic>.from(envelope['post'] as Map),
    );
  }

  Future<void> deletePost(String postId) =>
      _http.delete('${_base()}/posts/$postId');
}
