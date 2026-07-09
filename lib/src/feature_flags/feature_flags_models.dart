class FeatureFlag {
  const FeatureFlag({
    required this.id,
    required this.key,
    required this.enabled,
    this.name,
    this.description,
    this.rolloutPercent,
    this.countryMode,
    this.countryCodes,
    this.status,
    this.startsAt,
    this.endsAt,
  });

  final String id;
  final String key;
  final String? name;
  final String? description;
  final bool enabled;
  final double? rolloutPercent;
  final String? countryMode;
  final List<String>? countryCodes;
  final String? status;
  final String? startsAt;
  final String? endsAt;

  factory FeatureFlag.fromJson(Map<String, dynamic> json) {
    return FeatureFlag(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      enabled: json['enabled'] as bool? ?? false,
      rolloutPercent: (json['rolloutPercent'] as num?)?.toDouble(),
      countryMode: json['countryMode'] as String?,
      countryCodes: (json['countryCodes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(growable: false),
      status: json['status'] as String?,
      startsAt: json['startsAt'] as String?,
      endsAt: json['endsAt'] as String?,
    );
  }
}

class FeatureFlagsResponse {
  const FeatureFlagsResponse({
    required this.orgId,
    required this.flags,
    this.generatedAt,
  });

  final String orgId;
  final String? generatedAt;
  final List<FeatureFlag> flags;

  factory FeatureFlagsResponse.fromJson(Map<String, dynamic> json) {
    return FeatureFlagsResponse(
      orgId: json['orgId'] as String,
      generatedAt: json['generatedAt'] as String?,
      flags: (json['flags'] as List<dynamic>? ?? const [])
          .map((e) => FeatureFlag.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false),
    );
  }
}

class EvaluateFlagsRequest {
  const EvaluateFlagsRequest({
    required this.subjectId,
    this.countryCode,
    this.flagKeys,
  });

  final String subjectId;
  final String? countryCode;
  final List<String>? flagKeys;

  Map<String, dynamic> toJson() => {
        'subjectId': subjectId,
        if (countryCode != null) 'countryCode': countryCode,
        if (flagKeys != null) 'flagKeys': flagKeys,
      };
}

class EvaluateFlagsResponse {
  const EvaluateFlagsResponse({
    required this.orgId,
    required this.subjectId,
    required this.results,
    this.countryCode,
    this.evaluatedAt,
  });

  final String orgId;
  final String subjectId;
  final String? countryCode;
  final String? evaluatedAt;
  final Map<String, bool> results;

  factory EvaluateFlagsResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as Map? ?? const {};
    return EvaluateFlagsResponse(
      orgId: json['orgId'] as String,
      subjectId: json['subjectId'] as String,
      countryCode: json['countryCode'] as String?,
      evaluatedAt: json['evaluatedAt'] as String?,
      results: {
        for (final entry in rawResults.entries)
          entry.key.toString(): entry.value as bool,
      },
    );
  }
}
