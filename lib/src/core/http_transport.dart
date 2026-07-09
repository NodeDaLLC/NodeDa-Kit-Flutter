import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'node_da_transport.dart';

/// Default [NodeDaTransport] backed by `package:http`.
class HttpTransport implements NodeDaTransport {
  HttpTransport({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<NodeDaResponse> send(NodeDaRequest request) async {
    final req = http.Request(request.method, request.url);
    req.headers.addAll(request.headers);
    req.followRedirects = request.followRedirects;
    if (request.body != null) {
      req.bodyBytes = request.body!;
    }

    final streamed = await _client.send(req);
    final bodyBytes = await streamed.stream.toBytes();
    return NodeDaResponse(
      statusCode: streamed.statusCode,
      headers: Map<String, String>.from(streamed.headers),
      bodyBytes: Uint8List.fromList(bodyBytes),
      request: request,
    );
  }

  void close() => _client.close();
}
