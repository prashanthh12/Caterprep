import 'dart:io';

void main() async {
  final port = 8085;
  final dir = Directory('build/web');
  if (!dir.existsSync()) {
    print('Error: build/web not found');
    exit(1);
  }

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  print('Serving build/web on http://localhost:$port');

  await for (HttpRequest request in server) {
    try {
      var path = request.uri.path;
      if (path == '/' || path.isEmpty) path = '/index.html';

      var file = File('${dir.path}$path');
      if (!file.existsSync() || FileSystemEntity.isDirectorySync(file.path)) {
        file = File('${dir.path}/index.html');
      }

      if (file.existsSync()) {
        final ext = file.path.split('.').last.toLowerCase();
        final mimeTypes = {
          'html': 'text/html; charset=utf-8',
          'js': 'application/javascript; charset=utf-8',
          'mjs': 'application/javascript; charset=utf-8',
          'wasm': 'application/wasm',
          'css': 'text/css; charset=utf-8',
          'json': 'application/json; charset=utf-8',
          'png': 'image/png',
          'jpg': 'image/jpeg',
          'jpeg': 'image/jpeg',
          'svg': 'image/svg+xml',
          'ttf': 'font/ttf',
          'otf': 'font/otf',
          'woff': 'font/woff',
          'woff2': 'font/woff2',
        };

        final contentType = mimeTypes[ext] ?? 'application/octet-stream';
        request.response.headers.set('Content-Type', contentType);
        request.response.headers.set('Access-Control-Allow-Origin', '*');
        await request.response.addStream(file.openRead());
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write('Not found');
      }
    } catch (e) {
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write('Error: $e');
    } finally {
      await request.response.close();
    }
  }
}
