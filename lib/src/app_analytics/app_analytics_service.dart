import '../core/health_response.dart';
import '../core/http_client.dart';
import 'app_analytics_models.dart';

/// Client for the NodeDa Vertex App Analytics ingest API
/// (`https://api.nodeda.com` — schema `nrova.app-analytics.v1`).
///
/// POST session batches to `/v1/organizations/{orgId}/app-analytics/events`.
/// Apps auto-register from `bundleId`. Requires a developer API key with the
/// [AppAnalyticsScope.write] (`app-analytics:write`) scope.
/// `app-analytics:read` cannot ingest. `GET /health` needs no key.
///
/// Country and region are resolved server-side from the request IP. Never
/// send a raw IP or user identity.
///
/// ```dart
/// final result = await client.appAnalytics.ingest(
///   bundleId: 'com.example.notes',
///   platform: AppAnalyticsPlatform.android,
///   installId: AppAnalyticsOpaqueId.generate(),
///   sessionId: AppAnalyticsOpaqueId.generate(),
///   events: const [
///     AppAnalyticsEvent.sessionStart(),
///     AppAnalyticsEvent.screen('Home'),
///     AppAnalyticsEvent.heartbeat(foregroundDurationMs: 120000),
///   ],
/// );
/// print('${result.appId} active=${result.qualifiedActive}');
/// ```
class AppAnalyticsService {
  AppAnalyticsService({required HttpClient http, required String orgId})
      : _http = http,
        _orgId = orgId;

  final HttpClient _http;
  final String _orgId;

  String _base() => 'v1/organizations/$_orgId/app-analytics';

  /// `GET /health` — does not require an API key.
  Future<HealthResponse> health() => _http.get(
        'health',
        decode: (json) =>
            HealthResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
      );

  /// `POST …/app-analytics/events` — requires `app-analytics:write`.
  Future<AppAnalyticsIngestResponse> ingestEvents(
    AppAnalyticsIngestRequest request,
  ) =>
      _http.post(
        '${_base()}/events',
        body: request.toJson(),
        decode: (json) => AppAnalyticsIngestResponse.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );

  /// Sugar for [ingestEvents].
  Future<AppAnalyticsIngestResponse> ingest({
    required String bundleId,
    required AppAnalyticsPlatform platform,
    required String installId,
    required String sessionId,
    required List<AppAnalyticsEvent> events,
    AppAnalyticsSdk? sdk = AppAnalyticsSdk.flutter,
    String? appVersion,
    String? osVersion,
    int? activeUserThresholdSeconds,
  }) =>
      ingestEvents(
        AppAnalyticsIngestRequest(
          bundleId: bundleId,
          platform: platform,
          installId: installId,
          sessionId: sessionId,
          events: events,
          sdk: sdk,
          appVersion: appVersion,
          osVersion: osVersion,
          activeUserThresholdSeconds: activeUserThresholdSeconds,
        ),
      );
}
