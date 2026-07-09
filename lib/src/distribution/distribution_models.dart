/// Platforms supported by the Distribution API.
enum DistributionPlatform {
  macos('macos'),
  windows('windows');

  const DistributionPlatform(this.wire);
  final String wire;

  static DistributionPlatform? fromWire(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wire == value) return e;
    }
    return null;
  }

  static DistributionPlatform parse(String value) =>
      fromWire(value) ?? (throw FormatException('Unknown platform: $value'));
}

/// Release channels.
enum DistributionChannel {
  stable('stable'),
  beta('beta'),
  dev('dev');

  const DistributionChannel(this.wire);
  final String wire;

  static DistributionChannel? fromWire(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wire == value) return e;
    }
    return null;
  }

  static DistributionChannel parse(String value) =>
      fromWire(value) ?? (throw FormatException('Unknown channel: $value'));
}

/// Distinguishes installers from auto-update payloads.
enum DistributionArtifactPurpose {
  install('install'),
  update('update');

  const DistributionArtifactPurpose(this.wire);
  final String wire;

  static DistributionArtifactPurpose? fromWire(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wire == value) return e;
    }
    return null;
  }
}

/// Architectures the Distribution API reports for an artifact.
enum DistributionArchitecture {
  x64('x64'),
  arm64('arm64'),
  universal('universal'),
  x86('x86');

  const DistributionArchitecture(this.wire);
  final String wire;

  static DistributionArchitecture? fromWire(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wire == value) return e;
    }
    return null;
  }
}

/// A distribution application — typically one product line.
class DistributionApplication {
  const DistributionApplication({
    required this.id,
    required this.slug,
    required this.name,
    required this.platforms,
    this.bundleId,
    this.description,
    this.homepageUrl,
    this.iconUrl,
    this.iconStoragePath,
    this.isPublic,
    this.latest,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String slug;
  final String name;
  final List<DistributionPlatform> platforms;
  final String? bundleId;
  final String? description;
  final String? homepageUrl;
  final String? iconUrl;
  final String? iconStoragePath;
  final bool? isPublic;
  final Map<String, Map<String, DistributionLatestPointer>>? latest;
  final String? createdAt;
  final String? updatedAt;

  factory DistributionApplication.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, DistributionLatestPointer>>? latest;
    final rawLatest = json['latest'];
    if (rawLatest is Map) {
      latest = {
        for (final platformEntry in rawLatest.entries)
          platformEntry.key.toString(): {
            for (final channelEntry in (platformEntry.value as Map).entries)
              channelEntry.key.toString(): DistributionLatestPointer.fromJson(
                Map<String, dynamic>.from(channelEntry.value as Map),
              ),
          },
      };
    }

    return DistributionApplication(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      platforms: (json['platforms'] as List<dynamic>? ?? const [])
          .map((e) => DistributionPlatform.parse(e as String))
          .toList(growable: false),
      bundleId: json['bundleId'] as String?,
      description: json['description'] as String?,
      homepageUrl: json['homepageUrl'] as String?,
      iconUrl: json['iconUrl'] as String?,
      iconStoragePath: json['iconStoragePath'] as String?,
      isPublic: json['isPublic'] as bool?,
      latest: latest,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

/// Pointer to the most recent release for a platform/channel pair.
class DistributionLatestPointer {
  const DistributionLatestPointer({
    required this.releaseId,
    required this.version,
    this.updatedAt,
  });

  final String releaseId;
  final String version;
  final String? updatedAt;

  factory DistributionLatestPointer.fromJson(Map<String, dynamic> json) {
    return DistributionLatestPointer(
      releaseId: json['releaseId'] as String,
      version: json['version'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class DistributionRelease {
  const DistributionRelease({
    required this.id,
    required this.version,
    required this.channel,
    required this.isYanked,
    required this.artifacts,
    this.buildNumber,
    this.notes,
    this.releasedAt,
    this.updatedAt,
  });

  final String id;
  final String version;
  final DistributionChannel channel;
  final String? buildNumber;
  final String? notes;
  final bool isYanked;
  final String? releasedAt;
  final String? updatedAt;
  final List<DistributionArtifact> artifacts;

  factory DistributionRelease.fromJson(Map<String, dynamic> json) {
    return DistributionRelease(
      id: json['id'] as String,
      version: json['version'] as String,
      channel: DistributionChannel.parse(json['channel'] as String),
      buildNumber: json['buildNumber'] as String?,
      notes: json['notes'] as String?,
      isYanked: json['isYanked'] as bool? ?? false,
      releasedAt: json['releasedAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      artifacts: (json['artifacts'] as List<dynamic>? ?? const [])
          .map((e) => DistributionArtifact.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(growable: false),
    );
  }
}

class DistributionArtifact {
  const DistributionArtifact({
    required this.platform,
    required this.fileName,
    required this.downloadUrl,
    required this.sizeBytes,
    required this.contentType,
    this.sha256,
    this.version,
    this.buildNumber,
    this.minOsVersion,
    this.architecture,
    this.installPurpose,
    this.metadataAutoDetected,
  });

  final DistributionPlatform platform;
  final String fileName;
  final String downloadUrl;
  final int sizeBytes;
  final String contentType;
  final String? sha256;
  final String? version;
  final String? buildNumber;
  final String? minOsVersion;
  final DistributionArchitecture? architecture;
  final DistributionArtifactPurpose? installPurpose;
  final bool? metadataAutoDetected;

  factory DistributionArtifact.fromJson(Map<String, dynamic> json) {
    return DistributionArtifact(
      platform: DistributionPlatform.parse(json['platform'] as String),
      fileName: json['fileName'] as String,
      downloadUrl: json['downloadUrl'] as String,
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      contentType: json['contentType'] as String,
      sha256: json['sha256'] as String?,
      version: json['version'] as String?,
      buildNumber: json['buildNumber'] as String?,
      minOsVersion: json['minOsVersion'] as String?,
      architecture:
          DistributionArchitecture.fromWire(json['architecture'] as String?),
      installPurpose: DistributionArtifactPurpose.fromWire(
        json['installPurpose'] as String?,
      ),
      metadataAutoDetected: json['metadataAutoDetected'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'platform': platform.wire,
        'fileName': fileName,
        'downloadUrl': downloadUrl,
        'sizeBytes': sizeBytes,
        'contentType': contentType,
        if (sha256 != null) 'sha256': sha256,
        if (version != null) 'version': version,
        if (buildNumber != null) 'buildNumber': buildNumber,
        if (minOsVersion != null) 'minOsVersion': minOsVersion,
        if (architecture != null) 'architecture': architecture!.wire,
        if (installPurpose != null) 'installPurpose': installPurpose!.wire,
        if (metadataAutoDetected != null)
          'metadataAutoDetected': metadataAutoDetected,
      };
}

class DistributionApplicationsResponse {
  const DistributionApplicationsResponse({
    required this.applications,
    this.schema,
    this.orgId,
  });

  final String? schema;
  final String? orgId;
  final List<DistributionApplication> applications;

  factory DistributionApplicationsResponse.fromJson(Map<String, dynamic> json) {
    return DistributionApplicationsResponse(
      schema: json['schema'] as String?,
      orgId: json['orgId'] as String?,
      applications: (json['applications'] as List<dynamic>? ?? const [])
          .map((e) => DistributionApplication.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(growable: false),
    );
  }
}

class DistributionApplicationResponse {
  const DistributionApplicationResponse({
    required this.application,
    this.schema,
  });

  final String? schema;
  final DistributionApplication application;

  factory DistributionApplicationResponse.fromJson(Map<String, dynamic> json) {
    return DistributionApplicationResponse(
      schema: json['schema'] as String?,
      application: DistributionApplication.fromJson(
        Map<String, dynamic>.from(json['application'] as Map),
      ),
    );
  }
}

class DistributionReleasesResponse {
  const DistributionReleasesResponse({
    required this.releases,
    this.schema,
    this.appId,
  });

  final String? schema;
  final String? appId;
  final List<DistributionRelease> releases;

  factory DistributionReleasesResponse.fromJson(Map<String, dynamic> json) {
    return DistributionReleasesResponse(
      schema: json['schema'] as String?,
      appId: json['appId'] as String?,
      releases: (json['releases'] as List<dynamic>? ?? const [])
          .map((e) => DistributionRelease.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(growable: false),
    );
  }
}

class DistributionReleaseResponse {
  const DistributionReleaseResponse({required this.release, this.schema});

  final String? schema;
  final DistributionRelease release;

  factory DistributionReleaseResponse.fromJson(Map<String, dynamic> json) {
    return DistributionReleaseResponse(
      schema: json['schema'] as String?,
      release: DistributionRelease.fromJson(
        Map<String, dynamic>.from(json['release'] as Map),
      ),
    );
  }
}

class DistributionLatestResponse {
  const DistributionLatestResponse({
    required this.appId,
    required this.channel,
    required this.platform,
    required this.release,
    required this.artifact,
    this.schema,
  });

  final String? schema;
  final String appId;
  final DistributionChannel channel;
  final DistributionPlatform platform;
  final DistributionRelease release;
  final DistributionArtifact artifact;

  factory DistributionLatestResponse.fromJson(Map<String, dynamic> json) {
    return DistributionLatestResponse(
      schema: json['schema'] as String?,
      appId: json['appId'] as String,
      channel: DistributionChannel.parse(json['channel'] as String),
      platform: DistributionPlatform.parse(json['platform'] as String),
      release: DistributionRelease.fromJson(
        Map<String, dynamic>.from(json['release'] as Map),
      ),
      artifact: DistributionArtifact.fromJson(
        Map<String, dynamic>.from(json['artifact'] as Map),
      ),
    );
  }
}

class DistributionIconResponse {
  const DistributionIconResponse({
    required this.iconUrl,
    this.schema,
    this.appId,
    this.iconStoragePath,
  });

  final String? schema;
  final String? appId;
  final String iconUrl;
  final String? iconStoragePath;

  factory DistributionIconResponse.fromJson(Map<String, dynamic> json) {
    return DistributionIconResponse(
      schema: json['schema'] as String?,
      appId: json['appId'] as String?,
      iconUrl: json['iconUrl'] as String,
      iconStoragePath: json['iconStoragePath'] as String?,
    );
  }
}

class PublishReleaseRequest {
  const PublishReleaseRequest({
    required this.version,
    required this.channel,
    required this.artifacts,
    this.buildNumber,
    this.notes,
  });

  final String version;
  final DistributionChannel channel;
  final String? buildNumber;
  final String? notes;
  final List<DistributionArtifact> artifacts;

  Map<String, dynamic> toJson() => {
        'version': version,
        'channel': channel.wire,
        if (buildNumber != null) 'buildNumber': buildNumber,
        if (notes != null) 'notes': notes,
        'artifacts': artifacts.map((a) => a.toJson()).toList(growable: false),
      };
}

class UpdateReleaseRequest {
  const UpdateReleaseRequest({this.notes, this.isYanked});

  final String? notes;
  final bool? isYanked;

  Map<String, dynamic> toJson() => {
        if (notes != null) 'notes': notes,
        if (isYanked != null) 'isYanked': isYanked,
      };
}
