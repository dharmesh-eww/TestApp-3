import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('checked-in static recipe manifest matches its payload checksum and size', () async {
    final manifest = jsonDecode(await File('content/manifest.json').readAsString()) as Map<String, dynamic>;
    final recipeIndex = manifest['recipe_index'] as Map<String, dynamic>;
    final relativePath = recipeIndex['path'] as String;
    expect(relativePath.startsWith('/') || relativePath.contains('..'), isFalse);

    final bytes = await File('content/$relativePath').readAsBytes();
    expect(sha256.convert(bytes).toString(), recipeIndex['sha256']);
    final indexedFile = (manifest['files'] as List).cast<Map>().firstWhere(
      (item) => item['path'] == relativePath,
    );
    expect(bytes.length, indexedFile['byte_size']);
    expect(sha256.convert(bytes).toString(), indexedFile['sha256']);
  });
}
