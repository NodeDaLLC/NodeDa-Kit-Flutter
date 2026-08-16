/*
 * Illustrative usage of the NodeDa Flutter SDK. This file is NOT a runnable
 * app — paste patterns into your own Flutter project.
 *
 *     dependencies:
 *       nodeda:
 *         git:
 *           url: https://github.com/NodeDaLLC/NodeDa-Kit-Flutter.git
 */
import 'package:nodeda/nodeda.dart';

Future<void> main() async {
  // Prefer --dart-define or secure storage over hardcoding keys.
  final client = NodeDaClient.fromMap({
    'com.nodeda.sdk.ApiKey': const String.fromEnvironment('NODEDA_API_KEY'),
    // Optional: 'com.nodeda.sdk.OrganizationId': 'your-org-id',
  });

  print('NodeDa SDK ${NodeDa.version} booted');

  try {
    final latest = await client.distribution.latest(
      appId: 'acme-notes',
      platform: DistributionPlatform.macos,
      channel: DistributionChannel.stable,
    );
    final version = latest.artifact.version ?? latest.release.version;
    print('Latest version: $version');
    print('Download: ${latest.artifact.downloadUrl}');
  } on NodeDaApiException catch (e) {
    print('API error ${e.error.status}: ${e.error.code}');
  } on NodeDaTransportException catch (e) {
    print('Network problem: $e');
  }

  await client.support.createTicket(
    CreateSupportTicketRequest(
      contactEmail: 'user@example.com',
      applicationName: 'Acme Notes Flutter',
      subject: 'Crash on launch',
      body: 'App crashes immediately after splash screen.',
      priority: SupportPriority.high,
      category: SupportCategory.technical,
      environment: 'production',
    ),
  );

  final flags = await client.featureFlags.evaluate(
    EvaluateFlagsRequest(
      subjectId: 'user-1',
      countryCode: 'US',
      flagKeys: const ['dark_mode', 'new_onboarding'],
    ),
  );
  print('dark_mode = ${flags.results['dark_mode']}');

  final completion = await client.llmHub.chat(
    messages: const [
      ChatMessage(role: ChatMessageRole.user, content: 'Hello'),
    ],
  );
  print('LLM Hub: ${completion.firstContent}');

  final analytics = await client.appAnalytics.ingest(
    bundleId: 'com.example.notes',
    platform: AppAnalyticsPlatform.android,
    installId: AppAnalyticsOpaqueId.generate(),
    sessionId: AppAnalyticsOpaqueId.generate(),
    events: const [
      AppAnalyticsEvent.sessionStart(),
      AppAnalyticsEvent.screen('Home'),
      AppAnalyticsEvent.heartbeat(foregroundDurationMs: 120000),
    ],
  );
  print('App analytics: ${analytics.appId} active=${analytics.qualifiedActive}');

  // Firebase ID token for the signed-in NodeDa user (not an API key).
  const idToken = String.fromEnvironment('NODEDA_ID_TOKEN');
  final driveSession = await client.drive.session(idToken: idToken);
  final folder = await client.drive.createAppFolder(
    idToken: idToken,
    appKey: 'com.example.notes',
    name: 'Example Notes',
  );
  print('Drive folder: ${folder.folder.id} accounts=${driveSession.accounts.length}');

  // Runs all 11 /health endpoints concurrently.
  final health = await client.healthAll();
  health.forEach((name, response) {
    print('$name -> ${response.ok}');
  });
}
