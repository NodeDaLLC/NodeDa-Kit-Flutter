/// Wire `space`: `personal` (My Drive) or `shared` (Organization Drive).
enum DriveSpace {
  personal('personal'),
  shared('shared');

  const DriveSpace(this.wire);
  final String wire;

  static DriveSpace get my => DriveSpace.personal;
  static DriveSpace get organization => DriveSpace.shared;

  static DriveSpace? fromWire(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wire == value) return e;
    }
    return null;
  }
}

enum DriveItemKind {
  folder('folder'),
  file('file');

  const DriveItemKind(this.wire);
  final String wire;

  static DriveItemKind parse(String value) {
    for (final e in values) {
      if (e.wire == value) return e;
    }
    throw FormatException('Unknown DriveItemKind: $value');
  }
}

enum DriveConnectedKind {
  my('my'),
  organization('organization');

  const DriveConnectedKind(this.wire);
  final String wire;

  static DriveConnectedKind parse(String value) {
    for (final e in values) {
      if (e.wire == value) return e;
    }
    throw FormatException('Unknown DriveConnectedKind: $value');
  }
}

class DriveConnectedDrive {
  const DriveConnectedDrive({
    required this.kind,
    required this.space,
    required this.name,
  });

  final DriveConnectedKind kind;
  final DriveSpace space;
  final String name;

  factory DriveConnectedDrive.fromJson(Map<String, dynamic> json) {
    return DriveConnectedDrive(
      kind: DriveConnectedKind.parse(json['kind'] as String),
      space: DriveSpace.fromWire(json['space'] as String) ?? DriveSpace.personal,
      name: json['name'] as String,
    );
  }
}

/// Connected Drive account from `GET /v1/drive/session`.
/// [id] is opaque — not a Kit organization setting.
class DriveAccount {
  const DriveAccount({
    required this.id,
    required this.name,
    required this.driveAccessible,
    this.drives = const [],
  });

  final String id;
  final String name;
  final bool driveAccessible;
  final List<DriveConnectedDrive> drives;

  factory DriveAccount.fromJson(Map<String, dynamic> json) {
    return DriveAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      driveAccessible: json['driveAccessible'] as bool? ?? false,
      drives: (json['drives'] as List<dynamic>? ?? [])
          .map((e) => DriveConnectedDrive.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class DriveSessionUser {
  const DriveSessionUser({required this.uid, this.email, this.displayName});

  final String uid;
  final String? email;
  final String? displayName;

  factory DriveSessionUser.fromJson(Map<String, dynamic> json) {
    return DriveSessionUser(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
    );
  }
}

class DriveSession {
  const DriveSession({this.schema, required this.user, this.accounts = const []});

  final String? schema;
  final DriveSessionUser user;
  final List<DriveAccount> accounts;

  factory DriveSession.fromJson(Map<String, dynamic> json) {
    return DriveSession(
      schema: json['schema'] as String?,
      user: DriveSessionUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      accounts: (json['accounts'] as List<dynamic>? ?? [])
          .map((e) => DriveAccount.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class DriveUsage {
  const DriveUsage({required this.usedBytes, required this.quotaBytes});

  final int usedBytes;
  final int quotaBytes;

  factory DriveUsage.fromJson(Map<String, dynamic> json) {
    return DriveUsage(
      usedBytes: (json['usedBytes'] as num).toInt(),
      quotaBytes: (json['quotaBytes'] as num).toInt(),
    );
  }
}

class DriveUserResponse {
  const DriveUserResponse({
    this.schema,
    required this.user,
    required this.usage,
    this.drives = const [],
  });

  final String? schema;
  final DriveSessionUser user;
  final DriveUsage usage;
  final List<DriveConnectedDrive> drives;

  factory DriveUserResponse.fromJson(Map<String, dynamic> json) {
    return DriveUserResponse(
      schema: json['schema'] as String?,
      user: DriveSessionUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      usage: DriveUsage.fromJson(Map<String, dynamic>.from(json['usage'] as Map)),
      drives: (json['drives'] as List<dynamic>? ?? [])
          .map((e) => DriveConnectedDrive.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class DriveItem {
  const DriveItem({
    required this.id,
    required this.kind,
    required this.name,
    this.parentId,
    this.space = DriveSpace.personal,
    this.ownerUid,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.appKey,
    this.mimeType,
    this.sizeBytes,
    this.contentType,
  });

  final String id;
  final DriveItemKind kind;
  final String name;
  final String? parentId;
  final DriveSpace space;
  final String? ownerUid;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final String? appKey;
  final String? mimeType;
  final int? sizeBytes;
  final String? contentType;

  factory DriveItem.fromJson(Map<String, dynamic> json) {
    return DriveItem(
      id: json['id'] as String,
      kind: DriveItemKind.parse(json['kind'] as String),
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      space: DriveSpace.fromWire(json['space'] as String?) ?? DriveSpace.personal,
      ownerUid: json['ownerUid'] as String?,
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      appKey: json['appKey'] as String?,
      mimeType: json['mimeType'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      contentType: json['contentType'] as String?,
    );
  }
}

class DriveFolderResponse {
  const DriveFolderResponse({this.schema, this.created, required this.folder, this.user});

  final String? schema;
  final bool? created;
  final DriveItem folder;
  final DriveSessionUser? user;

  factory DriveFolderResponse.fromJson(Map<String, dynamic> json) {
    return DriveFolderResponse(
      schema: json['schema'] as String?,
      created: json['created'] as bool?,
      folder: DriveItem.fromJson(Map<String, dynamic>.from(json['folder'] as Map)),
      user: json['user'] == null
          ? null
          : DriveSessionUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
    );
  }
}

class DriveItemsResponse {
  const DriveItemsResponse({
    this.schema,
    this.parentId,
    this.space,
    this.items = const [],
    this.user,
  });

  final String? schema;
  final String? parentId;
  final DriveSpace? space;
  final List<DriveItem> items;
  final DriveSessionUser? user;

  factory DriveItemsResponse.fromJson(Map<String, dynamic> json) {
    return DriveItemsResponse(
      schema: json['schema'] as String?,
      parentId: json['parentId'] as String?,
      space: DriveSpace.fromWire(json['space'] as String?),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => DriveItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      user: json['user'] == null
          ? null
          : DriveSessionUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
    );
  }
}

class DriveItemResponse {
  const DriveItemResponse({this.schema, required this.item, this.user});

  final String? schema;
  final DriveItem item;
  final DriveSessionUser? user;

  factory DriveItemResponse.fromJson(Map<String, dynamic> json) {
    return DriveItemResponse(
      schema: json['schema'] as String?,
      item: DriveItem.fromJson(Map<String, dynamic>.from(json['item'] as Map)),
      user: json['user'] == null
          ? null
          : DriveSessionUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
    );
  }
}

class DriveInitUploadResponse {
  const DriveInitUploadResponse({
    this.schema,
    required this.fileId,
    required this.uploadUrl,
    this.uploadMethod,
    required this.storagePath,
    this.expiresAt,
    this.user,
  });

  final String? schema;
  final String fileId;
  final String uploadUrl;
  final String? uploadMethod;
  final String storagePath;
  final String? expiresAt;
  final DriveSessionUser? user;

  factory DriveInitUploadResponse.fromJson(Map<String, dynamic> json) {
    return DriveInitUploadResponse(
      schema: json['schema'] as String?,
      fileId: json['fileId'] as String,
      uploadUrl: json['uploadUrl'] as String,
      uploadMethod: json['uploadMethod'] as String?,
      storagePath: json['storagePath'] as String,
      expiresAt: json['expiresAt'] as String?,
      user: json['user'] == null
          ? null
          : DriveSessionUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
    );
  }
}

class DriveFileResponse {
  const DriveFileResponse({this.schema, required this.file, this.user});

  final String? schema;
  final DriveItem file;
  final DriveSessionUser? user;

  factory DriveFileResponse.fromJson(Map<String, dynamic> json) {
    return DriveFileResponse(
      schema: json['schema'] as String?,
      file: DriveItem.fromJson(Map<String, dynamic>.from(json['file'] as Map)),
      user: json['user'] == null
          ? null
          : DriveSessionUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
    );
  }
}

class DriveContentResponse {
  const DriveContentResponse({
    this.schema,
    required this.downloadUrl,
    this.expiresAt,
    this.item,
  });

  final String? schema;
  final String downloadUrl;
  final String? expiresAt;
  final DriveItem? item;

  factory DriveContentResponse.fromJson(Map<String, dynamic> json) {
    return DriveContentResponse(
      schema: json['schema'] as String?,
      downloadUrl: json['downloadUrl'] as String,
      expiresAt: json['expiresAt'] as String?,
      item: json['item'] == null
          ? null
          : DriveItem.fromJson(Map<String, dynamic>.from(json['item'] as Map)),
    );
  }
}
