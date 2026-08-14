import 'dart:math';

/// Schema id for the App Analytics ingest HTTP API.
abstract final class AppAnalyticsSchema {
  static const String v1 = 'nrova.app-analytics.v1';
}

/// Scopes required on Developer API keys for App Analytics.
///
/// Ingest requires [write]. [read] cannot ingest.
abstract final class AppAnalyticsScope {
  static const String write = 'app-analytics:write';
  static const String read = 'app-analytics:read';
}

/// Foreground seconds before an install counts as an active user.
abstract final class AppAnalyticsActiveUserThreshold {
  static const int defaultSeconds = 120;
  static const int minimum = 30;
  static const int maximum = 3600;
}

/// Wire `platform` for `POST …/app-analytics/events`.
enum AppAnalyticsPlatform {
  ios('ios'),
  android('android'),
  macos('macos'),
  windows('windows'),
  linux('linux'),
  other('other');

  const AppAnalyticsPlatform(this.wire);
  final String wire;

  static AppAnalyticsPlatform? fromWire(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wire == value) return e;
    }
    return null;
  }

  static AppAnalyticsPlatform parse(String value) =>
      fromWire(value) ?? (throw FormatException('Unknown platform: $value'));
}

/// Wire `sdk` for `POST …/app-analytics/events`.
enum AppAnalyticsSdk {
  flutter('flutter'),
  android('android'),
  ios('ios'),
  macos('macos'),
  reactNative('react-native'),
  unity('unity'),
  other('other');

  const AppAnalyticsSdk(this.wire);
  final String wire;

  static AppAnalyticsSdk? fromWire(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wire == value) return e;
    }
    return null;
  }

  static AppAnalyticsSdk parse(String value) =>
      fromWire(value) ?? (throw FormatException('Unknown sdk: $value'));
}

/// Event types accepted in an ingest batch (1–50 items).
enum AppAnalyticsEventType {
  sessionStart('session_start'),
  heartbeat('heartbeat'),
  screen('screen'),
  sessionEnd('session_end');

  const AppAnalyticsEventType(this.wire);
  final String wire;

  static AppAnalyticsEventType? fromWire(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wire == value) return e;
    }
    return null;
  }

  static AppAnalyticsEventType parse(String value) =>
      fromWire(value) ?? (throw FormatException('Unknown event type: $value'));
}

/// One event in an App Analytics ingest batch.
///
/// `screen` events require [screen]. Heartbeat / `session_end` may include
/// [foregroundDurationMs] (cumulative foreground time for the session).
/// Omit [ts] to let the server stamp the receive time. Never send a raw IP
/// or user identity — country and region are resolved server-side.
class AppAnalyticsEvent {
  const AppAnalyticsEvent({
    required this.type,
    this.ts,
    this.screen,
    this.foregroundDurationMs,
  });

  const AppAnalyticsEvent.sessionStart({this.ts})
      : type = AppAnalyticsEventType.sessionStart,
        screen = null,
        foregroundDurationMs = null;

  const AppAnalyticsEvent.heartbeat({this.ts, this.foregroundDurationMs})
      : type = AppAnalyticsEventType.heartbeat,
        screen = null;

  /// Developer-facing screen name (max 80 chars on the server).
  const AppAnalyticsEvent.screen(String name, {this.ts})
      : type = AppAnalyticsEventType.screen,
        screen = name,
        foregroundDurationMs = null;

  const AppAnalyticsEvent.sessionEnd({this.ts, this.foregroundDurationMs})
      : type = AppAnalyticsEventType.sessionEnd,
        screen = null;

  final AppAnalyticsEventType type;
  final int? ts;
  final String? screen;
  final int? foregroundDurationMs;

  Map<String, dynamic> toJson() => {
        'type': type.wire,
        if (ts != null) 'ts': ts,
        if (screen != null) 'screen': screen,
        if (foregroundDurationMs != null)
          'foregroundDurationMs': foregroundDurationMs,
      };

  factory AppAnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AppAnalyticsEvent(
      type: AppAnalyticsEventType.parse(json['type'] as String),
      ts: (json['ts'] as num?)?.toInt(),
      screen: json['screen'] as String?,
      foregroundDurationMs: (json['foregroundDurationMs'] as num?)?.toInt(),
    );
  }
}

/// Request body for `POST …/app-analytics/events`.
///
/// Apps auto-register from [bundleId]. JSON body limit is ~64 KB.
/// Rate limit is ~120 requests / minute / org+app+install.
class AppAnalyticsIngestRequest {
  const AppAnalyticsIngestRequest({
    required this.bundleId,
    required this.platform,
    required this.installId,
    required this.sessionId,
    required this.events,
    this.sdk,
    this.appVersion,
    this.osVersion,
    this.activeUserThresholdSeconds,
  });

  final String bundleId;
  final AppAnalyticsPlatform platform;
  final String installId;
  final String sessionId;
  final List<AppAnalyticsEvent> events;
  final AppAnalyticsSdk? sdk;
  final String? appVersion;
  final String? osVersion;
  final int? activeUserThresholdSeconds;

  Map<String, dynamic> toJson() => {
        'bundleId': bundleId,
        'platform': platform.wire,
        'installId': installId,
        'sessionId': sessionId,
        'events': events.map((e) => e.toJson()).toList(growable: false),
        if (sdk != null) 'sdk': sdk!.wire,
        if (appVersion != null) 'appVersion': appVersion,
        if (osVersion != null) 'osVersion': osVersion,
        if (activeUserThresholdSeconds != null)
          'activeUserThresholdSeconds': activeUserThresholdSeconds,
      };
}

/// Success body for `POST …/app-analytics/events` (`200`).
class AppAnalyticsIngestResponse {
  const AppAnalyticsIngestResponse({
    required this.ok,
    this.schema,
    this.appId,
    this.bundleId,
    this.qualifiedActive,
    this.activeUserThresholdSeconds,
  });

  final bool ok;
  final String? schema;
  final String? appId;
  final String? bundleId;
  final bool? qualifiedActive;
  final int? activeUserThresholdSeconds;

  factory AppAnalyticsIngestResponse.fromJson(Map<String, dynamic> json) {
    return AppAnalyticsIngestResponse(
      ok: json['ok'] as bool? ?? false,
      schema: json['schema'] as String?,
      appId: json['appId'] as String?,
      bundleId: json['bundleId'] as String?,
      qualifiedActive: json['qualifiedActive'] as bool?,
      activeUserThresholdSeconds:
          (json['activeUserThresholdSeconds'] as num?)?.toInt(),
    );
  }
}

/// Opaque install / session ids: 8–64 letters, digits, `_` or `-`.
/// Persist [installId] on device; mint a new session id each foreground.
abstract final class AppAnalyticsOpaqueId {
  static const String _alphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-';
  static final RegExp _pattern = RegExp(r'^[A-Za-z0-9_-]{8,64}$');

  static String generate({int length = 22, Random? random}) {
    final r = random ?? Random.secure();
    final n = length.clamp(8, 64);
    return String.fromCharCodes(
      Iterable.generate(
        n,
        (_) => _alphabet.codeUnitAt(r.nextInt(_alphabet.length)),
      ),
    );
  }

  static bool isValid(String value) => _pattern.hasMatch(value);
}
