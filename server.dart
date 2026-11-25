import 'dart:convert';
import 'dart:io';

const _upstreamHost = 'rajaongkir.komerce.id';

Future<void> main() async {
  final apiKey = Platform.environment['RAJAONGKIR_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('RAJAONGKIR_API_KEY belum diatur.');
    stderr.writeln(r'PowerShell: $env:RAJAONGKIR_API_KEY="API_KEY_ANDA"');
    exitCode = 1;
    return;
  }

  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  final client = HttpClient();
  stdout.writeln('Proxy RajaOngkir berjalan di http://localhost:$port');

  await for (final request in server) {
    _handleRequest(request, client, apiKey);
  }
}

Future<void> _handleRequest(
  HttpRequest request,
  HttpClient client,
  String apiKey,
) async {
  final origin = request.headers.value('origin');
  if (!_isLocalOrigin(origin)) {
    request.response
      ..statusCode = HttpStatus.forbidden
      ..write('Origin ditolak');
    await request.response.close();
    return;
  }

  final response = request.response;
  response.headers.set('Vary', 'Origin');
  if (origin != null) {
    response.headers.set('Access-Control-Allow-Origin', origin);
  }
  response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  response.headers.set('Access-Control-Allow-Headers', 'Content-Type');

  if (request.method == 'OPTIONS') {
    response.statusCode = HttpStatus.noContent;
    await response.close();
    return;
  }

  final path = request.uri.path;
  if (!_allowedRoute(request.method, path)) {
    response
      ..statusCode = HttpStatus.notFound
      ..write('Endpoint proxy tidak ditemukan');
    await response.close();
    return;
  }

  final body = await request.fold<List<int>>(
    <int>[],
    (bytes, chunk) => bytes..addAll(chunk),
  );
  if (body.length > 1024 * 1024) {
    response
      ..statusCode = HttpStatus.requestEntityTooLarge
      ..write('Request terlalu besar');
    await response.close();
    return;
  }

  try {
    final upstreamPath = '/api/v1/${path.substring('/api/'.length)}';
    final upstreamRequest = await client.openUrl(
      request.method,
      Uri.parse('https://$_upstreamHost$upstreamPath'),
    );
    upstreamRequest.headers.set('key', apiKey);
    final contentType = request.headers.contentType;
    if (contentType != null) {
      upstreamRequest.headers.contentType = contentType;
    }
    if (body.isNotEmpty) upstreamRequest.add(body);

    final upstreamResponse = await upstreamRequest.close();
    response.statusCode = upstreamResponse.statusCode;
    final upstreamContentType = upstreamResponse.headers.contentType;
    if (upstreamContentType != null) {
      response.headers.contentType = upstreamContentType;
    }
    await response.addStream(upstreamResponse);
  } catch (error) {
    stderr.writeln('Gagal menghubungi RajaOngkir: $error');
    response
      ..statusCode = HttpStatus.badGateway
      ..headers.contentType = ContentType.json;
    response.write(jsonEncode({'error': 'Proxy gagal menghubungi RajaOngkir.'}));
  } finally {
    await response.close();
  }
}

bool _isLocalOrigin(String? origin) {
  if (origin == null) return true;
  final uri = Uri.tryParse(origin);
  return uri != null &&
      (uri.host == 'localhost' || uri.host == '127.0.0.1');
}

bool _allowedRoute(String method, String path) {
  if (method == 'GET' && path == '/api/destination/province') return true;
  if (method == 'GET' &&
      RegExp(r'^/api/destination/(city|district)/\d+$').hasMatch(path)) {
    return true;
  }
  return method == 'POST' &&
      path == '/api/calculate/district/domestic-cost';
}
