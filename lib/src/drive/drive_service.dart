import '../core/health_response.dart';
import '../core/http_client.dart';
import 'drive_models.dart';

/// Client for the NodeDa Drive HTTP API (`nrova.drive.v1`).
///
/// Paths live under `/v1/drive/…` — not `/v1/organizations/{orgId}/…`.
/// Auth is a Firebase ID token for the signed-in NodeDa user (no developer
/// API key, no organization id). One login connects My Drive and
/// Organization Drive. If the user has more than one connected account,
/// pass [accountId] from [session].
class DriveService {
  DriveService({required HttpClient http}) : _http = http;

  final HttpClient _http;

  Map<String, String> _idHeaders(String idToken, String? accountId) {
    return {
      'Authorization': 'Bearer $idToken',
      'X-Firebase-Id-Token': idToken,
      if (accountId != null && accountId.isNotEmpty) 'X-NodeDa-Account': accountId,
    };
  }

  Map<String, String?> _accountQuery(String? accountId) => {'accountId': accountId};

  Future<HealthResponse> health() => _http.get(
        'health',
        decode: (json) => HealthResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
      );

  Future<DriveSession> session({required String idToken}) => _http.get(
        'v1/drive/session',
        decode: (json) => DriveSession.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
        extraHeaders: _idHeaders(idToken, null),
      );

  Future<DriveUserResponse> user({required String idToken, String? accountId}) => _http.get(
        'v1/drive/user',
        query: _accountQuery(accountId),
        decode: (json) => DriveUserResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
        extraHeaders: _idHeaders(idToken, accountId),
      );

  Future<DriveFolderResponse> createAppFolder({
    required String idToken,
    required String appKey,
    String? name,
    String? accountId,
  }) =>
      _http.post(
        'v1/drive/app-folders',
        query: _accountQuery(accountId),
        body: {
          'appKey': appKey,
          if (name != null) 'name': name,
        },
        decode: (json) => DriveFolderResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
        extraHeaders: _idHeaders(idToken, accountId),
      );

  Future<DriveFolderResponse> createFolder({
    required String idToken,
    required String name,
    String? parentId,
    DriveSpace? space,
    String? accountId,
  }) =>
      _http.post(
        'v1/drive/folders',
        query: _accountQuery(accountId),
        body: {
          'name': name,
          if (parentId != null) 'parentId': parentId,
          if (space != null) 'space': space.wire,
        },
        decode: (json) => DriveFolderResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
        extraHeaders: _idHeaders(idToken, accountId),
      );

  Future<DriveItemsResponse> listItems({
    required String idToken,
    String? parentId,
    DriveSpace space = DriveSpace.personal,
    int? limit,
    String? accountId,
  }) =>
      _http.get(
        'v1/drive/items',
        query: {
          ..._accountQuery(accountId),
          'parentId': parentId,
          'space': space.wire,
          if (limit != null) 'limit': '$limit',
        },
        decode: (json) => DriveItemsResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
        extraHeaders: _idHeaders(idToken, accountId),
      );

  Future<DriveItemResponse> getItem({
    required String idToken,
    required String itemId,
    String? accountId,
  }) =>
      _http.get(
        'v1/drive/items/$itemId',
        query: _accountQuery(accountId),
        decode: (json) => DriveItemResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
        extraHeaders: _idHeaders(idToken, accountId),
      );

  Future<void> trashItem({
    required String idToken,
    required String itemId,
    String? accountId,
  }) =>
      _http.delete(
        'v1/drive/items/$itemId',
        query: _accountQuery(accountId),
        authenticated: false,
        extraHeaders: _idHeaders(idToken, accountId),
      );

  Future<DriveInitUploadResponse> initiateUpload({
    required String idToken,
    required String name,
    required String mimeType,
    required int sizeBytes,
    String? parentId,
    String? accountId,
  }) =>
      _http.post(
        'v1/drive/files',
        query: _accountQuery(accountId),
        body: {
          'name': name,
          'mimeType': mimeType,
          'sizeBytes': sizeBytes,
          if (parentId != null) 'parentId': parentId,
        },
        decode: (json) => DriveInitUploadResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
        extraHeaders: _idHeaders(idToken, accountId),
      );

  Future<DriveFileResponse> finalizeUpload({
    required String idToken,
    required String fileId,
    required String name,
    required String storagePath,
    required int sizeBytes,
    required String mimeType,
    String? parentId,
    String? accountId,
  }) =>
      _http.post(
        'v1/drive/files/$fileId/finalize',
        query: _accountQuery(accountId),
        body: {
          'name': name,
          'storagePath': storagePath,
          'sizeBytes': sizeBytes,
          'mimeType': mimeType,
          if (parentId != null) 'parentId': parentId,
        },
        decode: (json) => DriveFileResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
        extraHeaders: _idHeaders(idToken, accountId),
      );

  Future<DriveContentResponse> content({
    required String idToken,
    required String fileId,
    String? accountId,
  }) =>
      _http.get(
        'v1/drive/files/$fileId/content',
        query: _accountQuery(accountId),
        decode: (json) => DriveContentResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        authenticated: false,
        extraHeaders: _idHeaders(idToken, accountId),
      );
}
