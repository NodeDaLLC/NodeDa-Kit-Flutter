enum LegalPolicyStatus {
  draft('draft'),
  published('published'),
  archived('archived');

  const LegalPolicyStatus(this.wire);
  final String wire;

  static LegalPolicyStatus? fromWire(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wire == value) return e;
    }
    return null;
  }
}

/// Stable policy keys present in the live NodeDa organization.
abstract final class LegalPolicyKey {
  static const String privacy = 'privacy';
  static const String privacyChoices = 'privacy_choices';
  static const String terms = 'terms';
}

class LegalPolicy {
  const LegalPolicy({
    required this.id,
    required this.key,
    required this.title,
    this.description,
    this.status,
    this.sectionCount,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String key;
  final String title;
  final String? description;
  final LegalPolicyStatus? status;
  final int? sectionCount;
  final String? createdAt;
  final String? updatedAt;

  factory LegalPolicy.fromJson(Map<String, dynamic> json) {
    return LegalPolicy(
      id: json['id'] as String,
      key: json['key'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: LegalPolicyStatus.fromWire(json['status'] as String?),
      sectionCount: (json['sectionCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class LegalPolicySection {
  const LegalPolicySection({
    required this.id,
    required this.body,
    this.title,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? title;
  final String body;
  final int? sortOrder;
  final String? createdAt;
  final String? updatedAt;

  factory LegalPolicySection.fromJson(Map<String, dynamic> json) {
    return LegalPolicySection(
      id: json['id'] as String,
      title: json['title'] as String?,
      body: json['body'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class LegalPoliciesResponse {
  const LegalPoliciesResponse({
    required this.policies,
    this.orgId,
    this.generatedAt,
  });

  final String? orgId;
  final List<LegalPolicy> policies;
  final String? generatedAt;

  factory LegalPoliciesResponse.fromJson(Map<String, dynamic> json) {
    return LegalPoliciesResponse(
      orgId: json['orgId'] as String?,
      policies: (json['policies'] as List<dynamic>? ?? const [])
          .map((e) => LegalPolicy.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false),
      generatedAt: json['generatedAt'] as String?,
    );
  }
}

class LegalPolicyResponse {
  const LegalPolicyResponse({
    required this.policy,
    required this.sections,
    this.orgId,
    this.generatedAt,
  });

  final String? orgId;
  final LegalPolicy policy;
  final List<LegalPolicySection> sections;
  final String? generatedAt;

  factory LegalPolicyResponse.fromJson(Map<String, dynamic> json) {
    return LegalPolicyResponse(
      orgId: json['orgId'] as String?,
      policy: LegalPolicy.fromJson(
        Map<String, dynamic>.from(json['policy'] as Map),
      ),
      sections: (json['sections'] as List<dynamic>? ?? const [])
          .map(
            (e) => LegalPolicySection.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(growable: false),
      generatedAt: json['generatedAt'] as String?,
    );
  }
}

class CreateLegalPolicyRequest {
  const CreateLegalPolicyRequest({
    required this.key,
    required this.title,
    this.description,
    this.status,
  });

  final String key;
  final String title;
  final String? description;
  final LegalPolicyStatus? status;

  Map<String, dynamic> toJson() => {
        'key': key,
        'title': title,
        if (description != null) 'description': description,
        if (status != null) 'status': status!.wire,
      };
}

class UpdateLegalPolicyRequest {
  const UpdateLegalPolicyRequest({
    this.title,
    this.description,
    this.status,
  });

  final String? title;
  final String? description;
  final LegalPolicyStatus? status;

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (status != null) 'status': status!.wire,
      };
}

class CreateLegalSectionRequest {
  const CreateLegalSectionRequest({
    required this.body,
    this.title,
    this.sortOrder,
  });

  final String? title;
  final String body;
  final int? sortOrder;

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        'body': body,
        if (sortOrder != null) 'sortOrder': sortOrder,
      };
}

class UpdateLegalSectionRequest {
  const UpdateLegalSectionRequest({
    this.title,
    this.body,
    this.sortOrder,
  });

  final String? title;
  final String? body;
  final int? sortOrder;

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (body != null) 'body': body,
        if (sortOrder != null) 'sortOrder': sortOrder,
      };
}
