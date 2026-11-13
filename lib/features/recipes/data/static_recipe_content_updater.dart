import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'recipe_catalog_loader.dart';

class ContentUpdateException implements Exception {
  const ContentUpdateException(this.code, this.message);
  final String code;
  final String message;
  @override
  String toString() => 'ContentUpdateException($code): $message';
}

class DownloadedRecipeCatalog {
  const DownloadedRecipeCatalog({required this.contentVersion, required this.payload, required this.document, required this.byteSize});
  final String contentVersion;
  final String payload;
  final RecipeCatalogDocument document;
  final int byteSize;
}

/// Downloads only public, read-only recipe content. Personal data is never sent.
class StaticRecipeContentUpdater {
  StaticRecipeContentUpdater({HttpClient? client}) : _client = client ?? HttpClient();
  final HttpClient _client;

  Future<DownloadedRecipeCatalog> checkAndDownload(Uri manifestUri) async {
    final manifestBytes = await _get(manifestUri);
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(manifestBytes));
    } on FormatException {
      throw const ContentUpdateException('invalid_manifest', 'The content manifest is not valid JSON.');
    }
    if (decoded is! Map<String, dynamic> || decoded['schema_version'] != 1) {
      throw const ContentUpdateException('unsupported_manifest', 'The content manifest schema is not supported.');
    }
    final version = decoded['content_version'], recipeIndex = decoded['recipe_index'];
    if (version is! String || version.trim().isEmpty || recipeIndex is! Map) {
      throw const ContentUpdateException('invalid_manifest', 'The manifest needs a content version and recipe index.');
    }
    final index = Map<String, dynamic>.from(recipeIndex);
    final path = index['path'], expectedHash = index['sha256'];
    if (path is! String || !_isSafeRelativePath(path) || expectedHash is! String ||
        !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(expectedHash)) {
      throw const ContentUpdateException('invalid_recipe_index', 'The recipe index path or SHA-256 checksum is invalid.');
    }
    final fileUri = manifestUri.resolve(path);
    if (fileUri.scheme != manifestUri.scheme || fileUri.host != manifestUri.host || fileUri.port != manifestUri.port) {
      throw const ContentUpdateException('external_content_path', 'Content files must use the manifest host.');
    }
    final payloadBytes = await _get(fileUri);
    if (sha256.convert(payloadBytes).toString().toLowerCase() != expectedHash.toLowerCase()) {
      throw const ContentUpdateException('checksum_mismatch', 'The downloaded recipe catalog failed its SHA-256 check.');
    }
    final declaredFiles = decoded['files'];
    if (declaredFiles is List) {
      for (final raw in declaredFiles.whereType<Map>()) {
        final file = Map<String, dynamic>.from(raw);
        if (file['path'] == path && file['byte_size'] is num &&
            (file['byte_size'] as num).toInt() != payloadBytes.length) {
          throw const ContentUpdateException('size_mismatch', 'The downloaded recipe catalog size does not match the manifest.');
        }
      }
    }
    final payload = utf8.decode(payloadBytes);
    final document = RecipeCatalogLoader.decode(payload);
    return DownloadedRecipeCatalog(contentVersion: version, payload: payload, document: document, byteSize: payloadBytes.length);
  }

  Future<List<int>> _get(Uri uri) async {
    final request = await _client.getUrl(uri).timeout(const Duration(seconds: 15));
    request.followRedirects = true;
    final response = await request.close().timeout(const Duration(seconds: 20));
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      throw ContentUpdateException('http_${response.statusCode}', 'Content request failed with HTTP ${response.statusCode}.');
    }
    return response.fold<List<int>>(<int>[], (bytes, chunk) => bytes..addAll(chunk));
  }

  bool _isSafeRelativePath(String path) {
    final uri = Uri.tryParse(path);
    return uri != null && !uri.hasScheme && !uri.hasAuthority && !path.startsWith('/') &&
        !uri.pathSegments.contains('..') && !uri.pathSegments.contains('.');
  }

  void close() => _client.close(force: true);
}
