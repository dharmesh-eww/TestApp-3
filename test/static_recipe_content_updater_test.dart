import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:testapp_3/features/recipes/data/static_recipe_content_updater.dart';

void main() {
  const catalog = '{"schema_version":1,"categories":[{"id":"dinner","name":"Dinner"}],"recipes":[{"id":"soup","title":"Tomato soup","description":"Warm","servings":2,"ingredients":[{"ingredient_id":"tomato","display_name":"Tomato","quantity":{"amount":2,"unit":"whole"}}],"instructions":[{"step":1,"text":"Simmer."}]}]}';

  test('downloads and validates a checksum-protected catalog', () async {
    final bytes = utf8.encode(catalog);
    final digest = sha256.convert(bytes).toString();
    final manifest = jsonEncode({
      'schema_version': 1,
      'content_version': 'test-2',
      'recipe_index': {'path': 'recipes/index.json', 'sha256': digest},
      'files': [{'path': 'recipes/index.json', 'byte_size': bytes.length}]
    });
    final client = MockClient((request) async => http.Response(
      request.url.path.endsWith('manifest.json') ? manifest : catalog,
      200,
      headers: {'content-type': 'application/json'},
    ));
    final updater = StaticRecipeContentUpdater(client: client);
    final result = await updater.checkAndDownload(Uri.parse('https://example.test/content/manifest.json'));
    expect(result.contentVersion, 'test-2');
    expect(result.document.recipes.single.id, 'soup');
    expect(result.byteSize, bytes.length);
    updater.close();
  });

  test('rejects a checksum mismatch before catalog activation', () async {
    final manifest = jsonEncode({
      'schema_version': 1,
      'content_version': 'bad',
      'recipe_index': {'path': 'recipes/index.json', 'sha256': '0' * 64}
    });
    final client = MockClient((request) async => http.Response(
      request.url.path.endsWith('manifest.json') ? manifest : catalog,
      200,
    ));
    final updater = StaticRecipeContentUpdater(client: client);
    await expectLater(
      updater.checkAndDownload(Uri.parse('https://example.test/content/manifest.json')),
      throwsA(isA<ContentUpdateException>().having((error) => error.code, 'code', 'checksum_mismatch')),
    );
    updater.close();
  });

  test('rejects path traversal in a manifest', () async {
    final manifest = jsonEncode({
      'schema_version': 1,
      'content_version': 'bad',
      'recipe_index': {'path': '../private.json', 'sha256': '0' * 64}
    });
    final client = MockClient((request) async => http.Response(manifest, 200));
    final updater = StaticRecipeContentUpdater(client: client);
    await expectLater(
      updater.checkAndDownload(Uri.parse('https://example.test/content/manifest.json')),
      throwsA(isA<ContentUpdateException>().having((error) => error.code, 'code', 'invalid_recipe_index')),
    );
    updater.close();
  });
}
