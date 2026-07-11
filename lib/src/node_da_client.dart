import 'careers/careers_service.dart';
import 'core/health_response.dart';
import 'core/http_client.dart';
import 'core/http_transport.dart';
import 'core/map_configuration.dart';
import 'core/node_da_configuration.dart';
import 'core/node_da_transport.dart';
import 'core/service_endpoints.dart';
import 'distribution/distribution_service.dart';
import 'feature_flags/feature_flags_service.dart';
import 'legal/legal_service.dart';
import 'llm_hub/llm_hub_service.dart';
import 'newsroom/newsroom_service.dart';
import 'sales/sales_service.dart';
import 'support/support_service.dart';
import 'system_status/system_status_service.dart';

/// Top-level entry point to all NodeDa HTTP APIs.
///
/// ```dart
/// final client = NodeDaClient(apiKey: 'sk_live_…');
/// final latest = await client.distribution.latest(
///   appId: 'acme-notes',
///   platform: DistributionPlatform.macos,
/// );
/// ```
class NodeDaClient {
  NodeDaClient._({
    required this.configuration,
    required this.transport,
  })  : distribution = DistributionService(
          http: HttpClient(
            baseUrl: configuration.endpoints.distribution,
            configuration: configuration,
            transport: transport,
          ),
          orgId: configuration.organizationId,
        ),
        support = SupportService(
          http: HttpClient(
            baseUrl: configuration.endpoints.support,
            configuration: configuration,
            transport: transport,
          ),
          orgId: configuration.organizationId,
        ),
        sales = SalesService(
          http: HttpClient(
            baseUrl: configuration.endpoints.sales,
            configuration: configuration,
            transport: transport,
          ),
          orgId: configuration.organizationId,
        ),
        careers = CareersService(
          http: HttpClient(
            baseUrl: configuration.endpoints.careers,
            configuration: configuration,
            transport: transport,
          ),
          orgId: configuration.organizationId,
        ),
        newsroom = NewsroomService(
          http: HttpClient(
            baseUrl: configuration.endpoints.newsroom,
            configuration: configuration,
            transport: transport,
          ),
          orgId: configuration.organizationId,
        ),
        featureFlags = FeatureFlagsService(
          http: HttpClient(
            baseUrl: configuration.endpoints.developer,
            configuration: configuration,
            transport: transport,
          ),
          orgId: configuration.organizationId,
        ),
        systemStatus = SystemStatusService(
          http: HttpClient(
            baseUrl: configuration.endpoints.systemStatus,
            configuration: configuration,
            transport: transport,
          ),
          orgId: configuration.organizationId,
        ),
        legal = LegalService(
          http: HttpClient(
            baseUrl: configuration.endpoints.legalPolicies,
            configuration: configuration,
            transport: transport,
          ),
          orgId: configuration.organizationId,
        ),
        llmHub = LLMHubService(
          http: HttpClient(
            baseUrl: configuration.endpoints.llmHub,
            configuration: configuration,
            transport: transport,
          ),
          orgId: configuration.organizationId,
        );

  /// Convenience: build a client with sane defaults from an API key.
  factory NodeDaClient({
    required String apiKey,
    String organizationId = NodeDaConfiguration.defaultOrganizationId,
    ServiceEndpoints? endpoints,
    Map<String, String> defaultHeaders = const {},
    Duration timeout = const Duration(seconds: 30),
    NodeDaTransport? transport,
  }) {
    return NodeDaClient.fromConfiguration(
      NodeDaConfiguration(
        apiKey: apiKey,
        organizationId: organizationId,
        endpoints: endpoints,
        defaultHeaders: defaultHeaders,
        timeout: timeout,
      ),
      transport: transport,
    );
  }

  /// Builds a fully wired client from an explicit [NodeDaConfiguration].
  factory NodeDaClient.fromConfiguration(
    NodeDaConfiguration configuration, {
    NodeDaTransport? transport,
  }) {
    return NodeDaClient._(
      configuration: configuration,
      transport: transport ?? HttpTransport(),
    );
  }

  /// In-memory credential loader — Flutter analog of Android `fromManifest`
  /// / Swift `fromInfoDictionary`.
  factory NodeDaClient.fromMap(
    Map<String, Object?> metadata, {
    MapKeys keys = const MapKeys(),
    String? packageName,
    ServiceEndpoints? endpoints,
    Map<String, String> defaultHeaders = const {},
    Duration timeout = const Duration(seconds: 30),
    NodeDaTransport? transport,
  }) {
    return NodeDaClient.fromConfiguration(
      MapConfiguration.fromMap(
        metadata,
        keys: keys,
        packageName: packageName,
        endpoints: endpoints,
        defaultHeaders: defaultHeaders,
        timeout: timeout,
      ),
      transport: transport,
    );
  }

  final NodeDaConfiguration configuration;
  final NodeDaTransport transport;

  final DistributionService distribution;
  final SupportService support;
  final SalesService sales;
  final CareersService careers;
  final NewsroomService newsroom;
  final FeatureFlagsService featureFlags;
  final SystemStatusService systemStatus;
  final LegalService legal;
  final LLMHubService llmHub;

  /// Issues `GET /health` against every service client in parallel.
  Future<Map<String, HealthResponse>> healthAll() async {
    final results = await Future.wait([
      distribution.health(),
      support.health(),
      sales.health(),
      careers.health(),
      newsroom.health(),
      featureFlags.health(),
      systemStatus.health(),
      legal.health(),
      llmHub.health(),
    ]);
    return {
      'distribution': results[0],
      'support': results[1],
      'sales': results[2],
      'careers': results[3],
      'newsroom': results[4],
      'featureFlags': results[5],
      'systemStatus': results[6],
      'legal': results[7],
      'llmHub': results[8],
    };
  }
}
