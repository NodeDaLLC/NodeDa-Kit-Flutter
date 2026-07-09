enum SystemStatusLevel {
  operational('operational'),
  degraded('degraded'),
  partialOutage('partial_outage'),
  majorOutage('major_outage'),
  maintenance('maintenance'),
  unknown('unknown');

  const SystemStatusLevel(this.wire);
  final String wire;

  static SystemStatusLevel? fromWire(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wire == value) return e;
    }
    return null;
  }
}

class SystemStatusComponent {
  const SystemStatusComponent({
    required this.id,
    this.key,
    this.name,
    this.description,
    this.status,
    this.sortOrder,
    this.updatedAt,
  });

  final String id;
  final String? key;
  final String? name;
  final String? description;
  final SystemStatusLevel? status;
  final int? sortOrder;
  final String? updatedAt;

  factory SystemStatusComponent.fromJson(Map<String, dynamic> json) {
    return SystemStatusComponent(
      id: json['id'] as String,
      key: json['key'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      status: SystemStatusLevel.fromWire(json['status'] as String?),
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class SystemStatusRollup {
  const SystemStatusRollup({
    required this.components,
    this.status,
    this.updatedAt,
  });

  final SystemStatusLevel? status;
  final String? updatedAt;
  final List<SystemStatusComponent> components;

  factory SystemStatusRollup.fromJson(Map<String, dynamic> json) {
    return SystemStatusRollup(
      status: SystemStatusLevel.fromWire(json['status'] as String?),
      updatedAt: json['updatedAt'] as String?,
      components: (json['components'] as List<dynamic>? ?? const [])
          .map(
            (e) => SystemStatusComponent.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(growable: false),
    );
  }
}

class CreateStatusComponentRequest {
  const CreateStatusComponentRequest({
    required this.key,
    required this.name,
    this.description,
    this.status,
    this.sortOrder,
  });

  final String key;
  final String name;
  final String? description;
  final SystemStatusLevel? status;
  final int? sortOrder;

  Map<String, dynamic> toJson() => {
        'key': key,
        'name': name,
        if (description != null) 'description': description,
        if (status != null) 'status': status!.wire,
        if (sortOrder != null) 'sortOrder': sortOrder,
      };
}

class UpdateStatusComponentRequest {
  const UpdateStatusComponentRequest({
    this.name,
    this.description,
    this.status,
    this.sortOrder,
  });

  final String? name;
  final String? description;
  final SystemStatusLevel? status;
  final int? sortOrder;

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (status != null) 'status': status!.wire,
        if (sortOrder != null) 'sortOrder': sortOrder,
      };
}
