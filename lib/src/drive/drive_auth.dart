import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../core/http_client.dart';
import '../core/http_transport.dart';
import '../core/node_da_configuration.dart';
import '../core/node_da_transport.dart';

/// PKCE verifier + S256 challenge for [DriveAuth].
class DrivePkce {
  const DrivePkce({required this.verifier, required this.challenge});

  final String verifier;
  final String challenge;
}

class DriveSignInTokens {
  const DriveSignInTokens({
    required this.tokenType,
    required this.idToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  final String tokenType;
  final String idToken;
  final String refreshToken;
  final int expiresIn;

  factory DriveSignInTokens.fromJson(Map<String, dynamic> json) {
    return DriveSignInTokens(
      tokenType: json['token_type'] as String? ?? 'Bearer',
      idToken: json['id_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
    );
  }
}

/// Website sign-in for third-party apps (PKCE). Open [authorizeUrl] in a
/// browser / in-app web view, then [exchange]. Lives on the NodeDa
/// **website**, not api.nodeda.com.
class DriveAuth {
  DriveAuth._();

  static const String defaultSite = 'https://vertex.nodeda.com';

  static DrivePkce makePkce() {
    final bytes = Uint8List(32);
    final rng = Random.secure();
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = rng.nextInt(256);
    }
    final verifier = _b64Url(bytes);
    final digest = sha256.convert(utf8.encode(verifier)).bytes;
    return DrivePkce(verifier: verifier, challenge: _b64Url(Uint8List.fromList(digest)));
  }

  static Uri authorizeUrl({
    required String clientId,
    required Uri redirectUri,
    required String state,
    required DrivePkce pkce,
    String? appName,
    String site = defaultSite,
  }) {
    return Uri.parse(site).replace(
      path: '/connect',
      queryParameters: {
        'client_id': clientId,
        'redirect_uri': redirectUri.toString(),
        'state': state,
        'code_challenge': pkce.challenge,
        'code_challenge_method': 'S256',
        if (appName != null && appName.isNotEmpty) 'name': appName,
      },
    );
  }

  static Future<DriveSignInTokens> exchange({
    required String code,
    required DrivePkce pkce,
    required String clientId,
    required Uri redirectUri,
    String site = defaultSite,
    NodeDaTransport? transport,
  }) {
    return _token(
      {
        'grant_type': 'authorization_code',
        'client_id': clientId,
        'redirect_uri': redirectUri.toString(),
        'code': code,
        'code_verifier': pkce.verifier,
      },
      site: site,
      transport: transport,
    );
  }

  static Future<DriveSignInTokens> refresh({
    required String refreshToken,
    required String clientId,
    String site = defaultSite,
    NodeDaTransport? transport,
  }) {
    return _token(
      {
        'grant_type': 'refresh_token',
        'client_id': clientId,
        'refresh_token': refreshToken,
      },
      site: site,
      transport: transport,
    );
  }

  static Future<DriveSignInTokens> _token(
    Map<String, String> body, {
    required String site,
    NodeDaTransport? transport,
  }) {
    final http = HttpClient(
      baseUrl: site,
      configuration: NodeDaConfiguration(apiKey: ''),
      transport: transport ?? HttpTransport(),
      requiresAuth: false,
    );
    return http.post(
      'api/connect/token',
      body: body,
      decode: (json) => DriveSignInTokens.fromJson(Map<String, dynamic>.from(json as Map)),
      authenticated: false,
    );
  }

  static String _b64Url(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');
}
