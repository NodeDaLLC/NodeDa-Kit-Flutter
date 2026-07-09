import 'dart:convert';
import 'dart:typed_data';

import 'package:nodeda/nodeda.dart';
import 'package:test/test.dart';

class MockTransport implements NodeDaTransport {
  MockTransport(this.responder);

  final (List<int>, int, Map<String, String>) Function(NodeDaRequest request)
      responder;

  factory MockTransport.json(String body, {int status = 200}) {
    return MockTransport(
      (_) => (utf8.encode(body), status, const {'content-type': 'application/json'}),
    );
  }

  @override
  Future<NodeDaResponse> send(NodeDaRequest request) async {
    final (bytes, status, headers) = responder(request);
    return NodeDaResponse(
      statusCode: status,
      headers: headers,
      bodyBytes: Uint8List.fromList(bytes),
      request: request,
    );
  }
}

void main() {
  group('configuration', () {
    test('default configuration uses production endpoints', () {
      final configuration = NodeDaConfiguration(apiKey: 'test');
      expect(
        configuration.organizationId,
        NodeDaConfiguration.defaultOrganizationId,
      );
      const unified = 'https://api.nodeda.com';
      expect(configuration.endpoints.distribution, unified);
      expect(configuration.endpoints.support, unified);
      expect(configuration.endpoints.sales, unified);
      expect(configuration.endpoints.careers, unified);
      expect(configuration.endpoints.newsroom, unified);
      expect(configuration.endpoints.developer, unified);
      expect(configuration.endpoints.systemStatus, unified);
      expect(configuration.endpoints.legalPolicies, unified);
      expect(ServiceEndpoints.unifiedApiBase, unified);
    });

    test('client exposes every service', () {
      final client = NodeDaClient(
        apiKey: 'test',
        transport: MockTransport.json('{}'),
      );
      expect(client.distribution, isNotNull);
      expect(client.support, isNotNull);
      expect(client.sales, isNotNull);
      expect(client.careers, isNotNull);
      expect(client.newsroom, isNotNull);
      expect(client.featureFlags, isNotNull);
      expect(client.systemStatus, isNotNull);
      expect(client.legal, isNotNull);
    });
  });

  group('distribution', () {
    test('listApplications sends the expected request', () async {
      const orgId = NodeDaConfiguration.defaultOrganizationId;
      final mock = MockTransport((request) {
        expect(request.method, 'GET');
        expect(
          request.url.toString(),
          'https://api.nodeda.com/v1/organizations/$orgId/applications',
        );
        expect(request.headers['Authorization'], 'Bearer test-key');
        expect(request.headers['X-API-Key'], 'test-key');

        final json = '''
{
  "schema": "nrova.distribution.v1",
  "orgId": "$orgId",
  "applications": [
    {
      "id": "acme-notes",
      "slug": "acme-notes",
      "name": "Acme Notes",
      "platforms": ["macos", "windows"],
      "createdAt": "2026-04-09T12:00:00.000Z",
      "updatedAt": "2026-06-01T14:00:00.000Z"
    }
  ]
}
''';
        return (utf8.encode(json), 200, const {});
      });

      final client = NodeDaClient(apiKey: 'test-key', transport: mock);
      final response = await client.distribution.listApplications();
      expect(response.applications, hasLength(1));
      expect(response.applications.first.id, 'acme-notes');
      expect(response.applications.first.platforms, [
        DistributionPlatform.macos,
        DistributionPlatform.windows,
      ]);
    });

    test('latest encodes query and decodes payload', () async {
      const orgId = NodeDaConfiguration.defaultOrganizationId;
      final mock = MockTransport((request) {
        expect(request.method, 'GET');
        expect(
          request.url.path,
          '/v1/organizations/$orgId/applications/acme-notes/latest',
        );
        expect(request.url.queryParameters['platform'], 'macos');
        expect(request.url.queryParameters['channel'], 'stable');
        expect(request.url.queryParameters['purpose'], 'install');

        final json = '''
{
  "schema": "nrova.distribution.v1",
  "appId": "acme-notes",
  "channel": "stable",
  "platform": "macos",
  "release": {
    "id": "rel_abc",
    "version": "1.2.3",
    "channel": "stable",
    "isYanked": false,
    "artifacts": [
      {
        "platform": "macos",
        "fileName": "Acme-Notes-1.2.3.dmg",
        "downloadUrl": "https://example.com/file.dmg",
        "sizeBytes": 100,
        "contentType": "application/x-apple-diskimage",
        "installPurpose": "install"
      }
    ]
  },
  "artifact": {
    "platform": "macos",
    "fileName": "Acme-Notes-1.2.3.dmg",
    "downloadUrl": "https://example.com/file.dmg",
    "sizeBytes": 100,
    "contentType": "application/x-apple-diskimage",
    "installPurpose": "install"
  }
}
''';
        return (utf8.encode(json), 200, const {});
      });

      final client = NodeDaClient(apiKey: 'test-key', transport: mock);
      final latest = await client.distribution.latest(
        appId: 'acme-notes',
        platform: DistributionPlatform.macos,
        channel: DistributionChannel.stable,
        purpose: DistributionArtifactPurpose.install,
      );
      expect(latest.appId, 'acme-notes');
      expect(latest.platform, DistributionPlatform.macos);
      expect(latest.artifact.fileName, 'Acme-Notes-1.2.3.dmg');
      expect(latest.artifact.installPurpose, DistributionArtifactPurpose.install);
    });

    test('publishRelease sends body', () async {
      final mock = MockTransport((request) {
        expect(request.method, 'POST');
        expect(request.headers['Content-Type'], 'application/json');

        final sent =
            jsonDecode(utf8.decode(request.body!)) as Map<String, dynamic>;
        expect(sent['version'], '1.2.4');
        expect(sent['channel'], 'stable');

        final json = '''
{
  "schema": "nrova.distribution.v1",
  "release": {
    "id": "rel_new",
    "version": "1.2.4",
    "channel": "stable",
    "isYanked": false,
    "artifacts": [
      {
        "platform": "macos",
        "fileName": "Acme.zip",
        "downloadUrl": "https://example.com/file.zip",
        "sizeBytes": 200,
        "contentType": "application/zip"
      }
    ]
  }
}
''';
        return (utf8.encode(json), 200, const {});
      });

      final client = NodeDaClient(apiKey: 'test-key', transport: mock);
      final release = await client.distribution.publishRelease(
        appId: 'acme-notes',
        request: PublishReleaseRequest(
          version: '1.2.4',
          channel: DistributionChannel.stable,
          artifacts: const [
            DistributionArtifact(
              platform: DistributionPlatform.macos,
              fileName: 'Acme.zip',
              downloadUrl: 'https://example.com/file.zip',
              sizeBytes: 200,
              contentType: 'application/zip',
            ),
          ],
        ),
      );
      expect(release.id, 'rel_new');
    });
  });

  group('errors', () {
    test('api error is surfaced', () async {
      final mock = MockTransport.json(
        '{"error":"invalid_api_key","message":"Missing or unrecognized key."}',
        status: 401,
      );
      final client = NodeDaClient(apiKey: 'bad', transport: mock);

      try {
        await client.distribution.listApplications();
        fail('expected NodeDaApiException');
      } on NodeDaApiException catch (e) {
        expect(e.error.status, 401);
        expect(e.error.code, 'invalid_api_key');
        expect(e.error.message, 'Missing or unrecognized key.');
      }
    });
  });

  group('feature flags', () {
    test('evaluate posts body', () async {
      const orgId = NodeDaConfiguration.defaultOrganizationId;
      final mock = MockTransport((request) {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'https://api.nodeda.com/v1/organizations/$orgId/evaluate',
        );

        final sent =
            jsonDecode(utf8.decode(request.body!)) as Map<String, dynamic>;
        expect(sent['subjectId'], 'user-1');
        expect(sent['countryCode'], 'US');

        final json = '''
{
  "orgId": "$orgId",
  "subjectId": "user-1",
  "countryCode": "US",
  "evaluatedAt": "2026-06-09T00:00:00.000Z",
  "results": { "dark_mode": true }
}
''';
        return (utf8.encode(json), 200, const {});
      });

      final client = NodeDaClient(apiKey: 'test-key', transport: mock);
      final enabled = await client.featureFlags.isEnabled(
        flagKey: 'dark_mode',
        subjectId: 'user-1',
        countryCode: 'US',
      );
      expect(enabled, isTrue);
    });
  });

  group('map configuration', () {
    test('uses provided key and org', () {
      final configuration = MapConfiguration.fromMap({
        'com.nodeda.sdk.ApiKey': 'sk_test_abc',
        'com.nodeda.sdk.OrganizationId': 'TenantXYZ',
      });
      expect(configuration.apiKey, 'sk_test_abc');
      expect(configuration.organizationId, 'TenantXYZ');
    });

    test('trims whitespace and falls back to default org', () {
      final configuration = MapConfiguration.fromMap({
        'com.nodeda.sdk.ApiKey': '  sk_test_abc  ',
      });
      expect(configuration.apiKey, 'sk_test_abc');
      expect(
        configuration.organizationId,
        NodeDaConfiguration.defaultOrganizationId,
      );
    });

    test('honours custom key names', () {
      final configuration = MapConfiguration.fromMap(
        {
          'myapp.NodeDaKey': 'sk_test_abc',
          'myapp.NodeDaOrg': 'TenantXYZ',
        },
        keys: const MapKeys(
          apiKey: 'myapp.NodeDaKey',
          organizationId: 'myapp.NodeDaOrg',
        ),
      );
      expect(configuration.apiKey, 'sk_test_abc');
      expect(configuration.organizationId, 'TenantXYZ');
    });

    test('throws when api key missing', () {
      expect(
        () => MapConfiguration.fromMap({}),
        throwsA(isA<MissingApiKeyException>()),
      );
    });

    test('throws when api key empty', () {
      expect(
        () => MapConfiguration.fromMap({'com.nodeda.sdk.ApiKey': '   '}),
        throwsA(isA<MissingApiKeyException>()),
      );
    });

    test('throws when organization empty', () {
      expect(
        () => MapConfiguration.fromMap({
          'com.nodeda.sdk.ApiKey': 'sk_test_abc',
          'com.nodeda.sdk.OrganizationId': '',
        }),
        throwsA(isA<EmptyOrganizationIdException>()),
      );
    });

    test('NodeDaClient.fromMap wires everything', () {
      final client = NodeDaClient.fromMap(
        {'com.nodeda.sdk.ApiKey': 'sk_test_abc'},
        transport: MockTransport.json('{}'),
      );
      expect(client.configuration.apiKey, 'sk_test_abc');
      expect(
        client.configuration.organizationId,
        NodeDaConfiguration.defaultOrganizationId,
      );
    });
  });

  group('version', () {
    test('SDK version is exposed', () {
      expect(NodeDa.version, isNotEmpty);
      expect(NodeDa.version, '1.1.0');
    });
  });

  group('health', () {
    test('health endpoint skips auth', () async {
      final mock = MockTransport((request) {
        expect(request.headers.containsKey('Authorization'), isFalse);
        expect(request.headers.containsKey('X-API-Key'), isFalse);
        return (
          utf8.encode('{"ok":true,"service":"distribution-api"}'),
          200,
          const {},
        );
      });
      final client = NodeDaClient(apiKey: 'test-key', transport: mock);
      final health = await client.distribution.health();
      expect(health.ok, isTrue);
      expect(health.service, 'distribution-api');
    });
  });
}
