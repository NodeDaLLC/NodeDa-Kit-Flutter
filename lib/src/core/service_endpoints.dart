/// Base URLs for each NodeDa service client.
///
/// Production traffic goes through the unified API gateway
/// (`https://api.nodeda.com`). Per-service fields remain so callers can
/// override individual bases (e.g. staging proxies).
class ServiceEndpoints {
  const ServiceEndpoints({
    required this.distribution,
    required this.support,
    required this.sales,
    required this.careers,
    required this.newsroom,
    required this.developer,
    required this.systemStatus,
    required this.legalPolicies,
    required this.llmHub,
  });

  /// Unified production API gateway (no trailing slash).
  static const String unifiedApiBase = 'https://api.nodeda.com';

  /// All services pointed at [unifiedApiBase].
  static final ServiceEndpoints production = ServiceEndpoints.of(unifiedApiBase);

  final String distribution;
  final String support;
  final String sales;
  final String careers;
  final String newsroom;
  final String developer;
  final String systemStatus;
  final String legalPolicies;
  final String llmHub;

  /// Builds endpoints where every service shares [base].
  factory ServiceEndpoints.of(String base) {
    final normalized = _stripTrailingSlash(base);
    return ServiceEndpoints(
      distribution: normalized,
      support: normalized,
      sales: normalized,
      careers: normalized,
      newsroom: normalized,
      developer: normalized,
      systemStatus: normalized,
      legalPolicies: normalized,
      llmHub: normalized,
    );
  }

  static String _stripTrailingSlash(String url) {
    if (url.endsWith('/')) return url.substring(0, url.length - 1);
    return url;
  }
}
