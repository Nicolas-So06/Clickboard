import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../supabase_config.dart';

class SupabaseStorageService {
  final http.Client _client;

  SupabaseStorageService({http.Client? client})
      : _client = client ?? http.Client();

  String get _bucket => SupabaseConfig.documentsBucket;

  Map<String, String> get _authHeaders => {
        'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
        'apikey': SupabaseConfig.anonKey,
      };

  Future<String> upload({
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final uri =
        Uri.parse('${SupabaseConfig.url}/storage/v1/object/$_bucket/$path');
    final response = await _client.post(
      uri,
      headers: {
        ..._authHeaders,
        'Content-Type': contentType ?? 'application/octet-stream',
        'x-upsert': 'true',
      },
      body: bytes,
    );
    if (response.statusCode != 200) {
      throw Exception('Falha no upload (${response.statusCode})');
    }
    return '${SupabaseConfig.url}/storage/v1/object/public/$_bucket/$path';
  }

  Future<void> delete(String path) async {
    final uri =
        Uri.parse('${SupabaseConfig.url}/storage/v1/object/$_bucket/$path');
    final response = await _client.delete(uri, headers: _authHeaders);
    if (response.statusCode != 200) {
      throw Exception('Falha ao excluir (${response.statusCode})');
    }
  }
}
