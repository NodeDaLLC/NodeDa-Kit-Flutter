import '../core/health_response.dart';
import '../core/http_client.dart';
import '../core/node_da_error.dart';
import 'distribution_models.dart';

/// How [DistributionService.icon] should resolve the icon payload.
enum IconFormat { json, redirect }

/// Client for the NodeDa Distribution API.
class DistributionService {
  DistributionService({required HttpClient http, required String orgId})
      : _http = http,
        _orgId = orgId;

  final HttpClient _http;
  final String _orgId;

  String _base() => 'v1/organizations/$_orgId/applications';

  /// `GET /health` — does not require an API key.
  Future<HealthResponse> health() => _http.get(
        'health',
        decode: (json) =>
            HealthResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
      );

  /// Unauthenticated public app feed.
  Future<DistributionApplicationsResponse> listPublicApplications() =>
      _http.get(
        '${_base()}/public',
        decode: (json) => DistributionApplicationsResponse.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        authenticated: false,
      );

  /// `GET …/applications` — requires `distribution:read`.
  Future<DistributionApplicationsResponse> listApplications() => _http.get(
        _base(),
        decode: (json) => DistributionApplicationsResponse.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );

  /// `GET …/applications/{appId}`.
  Future<DistributionApplication> getApplication(String appId) async {
    final envelope = await _http.get(
      '${_base()}/$appId',
      decode: (json) => DistributionApplicationResponse.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    return envelope.application;
  }

  /// `GET …/applications/{appId}/releases`.
  Future<List<DistributionRelease>> listReleases(
    String appId, {
    DistributionChannel? channel,
    DistributionPlatform? platform,
    int? limit,
  }) async {
    final envelope = await _http.get(
      '${_base()}/$appId/releases',
      decode: (json) => DistributionReleasesResponse.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
      query: {
        'channel': channel?.wire,
        'platform': platform?.wire,
        'limit': limit?.toString(),
      },
    );
    return envelope.releases;
  }

  /// `GET …/applications/{appId}/releases/{releaseId}`.
  Future<DistributionRelease> getRelease(String appId, String releaseId) async {
    final envelope = await _http.get(
      '${_base()}/$appId/releases/$releaseId',
      decode: (json) => DistributionReleaseResponse.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    return envelope.release;
  }

  /// `GET …/applications/{appId}/latest`.
  Future<DistributionLatestResponse> latest({
    required String appId,
    required DistributionPlatform platform,
    DistributionChannel channel = DistributionChannel.stable,
    DistributionArtifactPurpose? purpose,
  }) =>
      _http.get(
        '${_base()}/$appId/latest',
        decode: (json) => DistributionLatestResponse.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        query: {
          'platform': platform.wire,
          'channel': channel.wire,
          'purpose': purpose?.wire,
        },
      );

  /// Resolves the final download URL from the `Location` header of a 302.
  Future<String> resolveDownloadUrl({
    required String appId,
    required DistributionPlatform platform,
    DistributionChannel channel = DistributionChannel.stable,
    DistributionArtifactPurpose purpose = DistributionArtifactPurpose.install,
  }) async {
    final resp = await _http.head(
      '${_base()}/$appId/download',
      query: {
        'platform': platform.wire,
        'channel': channel.wire,
        'purpose': purpose.wire,
      },
    );
    final location = resp.header('Location');
    if (location == null || location.isEmpty) {
      throw NodeDaUnexpectedStatusException(resp.statusCode);
    }
    return location;
  }

  /// Returns the public icon URL for an app.
  Future<DistributionIconResponse> icon(
    String appId, {
    IconFormat format = IconFormat.json,
  }) async {
    switch (format) {
      case IconFormat.json:
        return _http.get(
          '${_base()}/$appId/icon',
          decode: (json) => DistributionIconResponse.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
          query: const {'format': 'json'},
        );
      case IconFormat.redirect:
        final resp = await _http.head('${_base()}/$appId/icon');
        final location = resp.header('Location');
        if (location == null) {
          throw NodeDaUnexpectedStatusException(resp.statusCode);
        }
        return DistributionIconResponse(appId: appId, iconUrl: location);
    }
  }

  /// `POST …/applications/{appId}/releases` — requires `distribution:write`.
  Future<DistributionRelease> publishRelease({
    required String appId,
    required PublishReleaseRequest request,
  }) async {
    final envelope = await _http.post(
      '${_base()}/$appId/releases',
      body: request.toJson(),
      decode: (json) => DistributionReleaseResponse.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    return envelope.release;
  }

  /// `PATCH …/applications/{appId}/releases/{releaseId}`.
  Future<DistributionRelease> updateRelease({
    required String appId,
    required String releaseId,
    required UpdateReleaseRequest update,
  }) async {
    final envelope = await _http.patch(
      '${_base()}/$appId/releases/$releaseId',
      body: update.toJson(),
      decode: (json) => DistributionReleaseResponse.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    return envelope.release;
  }
}
