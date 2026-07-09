import 'node_da_configuration.dart';
import 'service_endpoints.dart';

/// Loads credentials from a map — Flutter analog of Android's
/// `ManifestConfiguration` / Swift's Info.plist loader.
///
/// Typical Flutter usage: `--dart-define`, env files, or secure storage
/// mapped into the same key names.
class MapConfiguration {
  MapConfiguration._();

  /// Default meta-data style key names (mirrors Android/Swift).
  static const String defaultApiKeyName = 'com.nodeda.sdk.ApiKey';
  static const String defaultOrganizationIdName = 'com.nodeda.sdk.OrganizationId';

  /// Build a configuration from [metadata].
  ///
  /// Throws [MapConfigurationException] when required entries are missing.
  static NodeDaConfiguration fromMap(
    Map<String, Object?> metadata, {
    MapKeys keys = const MapKeys(),
    String? packageName,
    ServiceEndpoints? endpoints,
    Map<String, String> defaultHeaders = const {},
    Duration timeout = const Duration(seconds: 30),
  }) {
    final raw = metadata[keys.apiKey]?.toString().trim();
    if (raw == null || raw.isEmpty) {
      throw MissingApiKeyException(manifestKey: keys.apiKey, packageName: packageName);
    }

    final rawOrg = metadata[keys.organizationId]?.toString();
    final String orgId;
    if (rawOrg != null) {
      final trimmed = rawOrg.trim();
      if (trimmed.isEmpty) {
        throw EmptyOrganizationIdException(
          manifestKey: keys.organizationId,
          packageName: packageName,
        );
      }
      orgId = trimmed;
    } else {
      orgId = NodeDaConfiguration.defaultOrganizationId;
    }

    return NodeDaConfiguration(
      apiKey: raw,
      organizationId: orgId,
      endpoints: endpoints,
      defaultHeaders: defaultHeaders,
      timeout: timeout,
    );
  }
}

/// Key names used by [MapConfiguration.fromMap].
class MapKeys {
  const MapKeys({
    this.apiKey = MapConfiguration.defaultApiKeyName,
    this.organizationId = MapConfiguration.defaultOrganizationIdName,
  });

  final String apiKey;
  final String organizationId;

  static const MapKeys defaults = MapKeys();
}

/// Errors raised when map-based configuration is invalid.
sealed class MapConfigurationException implements Exception {
  const MapConfigurationException(this.message);
  final String message;

  @override
  String toString() => message;
}

final class MissingApiKeyException extends MapConfigurationException {
  MissingApiKeyException({required this.manifestKey, this.packageName})
      : super(
          'NodeDa: missing API key. Provide "$manifestKey"'
          '${packageName != null ? ' for package $packageName' : ''}.',
        );

  final String manifestKey;
  final String? packageName;
}

final class EmptyOrganizationIdException extends MapConfigurationException {
  EmptyOrganizationIdException({required this.manifestKey, this.packageName})
      : super(
          'NodeDa: "$manifestKey"'
          '${packageName != null ? ' for package $packageName' : ''}'
          ' is empty. Remove it to fall back to the default organization, '
          'or set a non-empty string.',
        );

  final String manifestKey;
  final String? packageName;
}
