import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/recipes/data/static_recipe_content_updater.dart';

void main() {
  const catalog = '''
{"schema_version":1,"categories":[{"id":"dinner","name":"Dinner"}],"recipes":[{"id":"soup","title":"Tomato soup","description":"Warm","servings":2,"ingredients":[{"ingredient_id":"tomato","display_name":"Tomato","quantity":{"amount":2,"unit":"whole"}}],"instructions":[{"step":1,"text":"Simmer."}]}]}
''';

  Future<HttpServer> serve(Future<void> Function(HttpRequest) handler) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async { await handler(request); });
    return server;
  }

  test('downloads and validates a checksum-protected catalog', () async {
    final bytes = utf8.encode(catalog);
    final digest = sha256.convert(bytes).toString();
    final manifest = jsonEncode({
      'schema_version': 1,
      'content_version': 'test-2',
      'recipe_index': {'path': 'recipes/index.json', 'sha256': digest},
      'files': [{'path': 'recipes/index.json', 'byte_size': bytes.length}]
    });
    final server = await serve((request) async {
      request.response.headers.contentType = ContentType.json;
      request.response.write(request.uri.path.endsWith('manifest.json') ? manifest : catalog);
      await request.response.close();
    });
    final updater = StaticRecipeContentUpdater();
    try {
      final result = await updater.checkAndDownload(
        Uri.parse('http://127.0.0.1:${server.port}/content/manifest.json'),
      );
      expect(result.contentVersion, 'test-2');
      expect(result.document.recipes.single.id, 'soup');
      expect(result.byteSize, bytes.length);
    } finally {
      updater.close();
      await server.close(force: true);
    }
  });

  test('rejects a checksum mismatch before catalog activation', () async {
    final manifest = jsonEncode({
      'schema_version': 1,
      'content_version': 'bad',
      'recipe_index': {'path': 'recipes/index.json', 'sha256': '0' * 64}
    });
    final server = await serve((request) async {
      request.response.write(request.uri.path.endsWith('manifest.json') ? manifest : catalog);
      await request.response.close();
    });
    final updater = StaticRecipeContentUpdater();
    try {
      await expectLater(
        updater.checkAndDownload(Uri.parse('http://127.0.0.1:${server.port}/content/manifest.json')),
        throwsA(isA<ContentUpdateException>().having((error) => error.code, 'code', 'checksum_mismatch')),
      );
    } finally {
      updater.close();
      await server.close(force: true);
    }
  });

  test('rejects path traversal in a manifest', () async {
    final manifest = jsonEncode({
      'schema_version': 1,
      'content_version': 'bad',
      'recipe_index': {'path': '../private.json', 'sha256': '0' * 64}
    });
    final server = await serve((request) async {
      request.response.write(manifest);
      await request.response.close();
    });
    final updater = StaticRecipeContentUpdater();
    try {
      await expectLater(
        updater.checkAndDownload(Uri.parse('http://127.0.0.1:${server.port}/content/manifest.json')),
        throwsA(isA<ContentUpdateException>().having((error) => error.code, 'code', 'invalid_recipe_index')),
      );
    } finally {
      updater.close();
      await server.close(force: true);
    }
  });
}
