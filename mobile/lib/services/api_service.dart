import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/models.dart';
import 'local_catalog.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Cliente da API com fallback automático para [LocalCatalog] se a rede falhar.
class ApiService {
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  /// `true` quando a última leitura bem-sucedida veio do JSON embutido.
  final ValueNotifier<bool> usingOfflineData = ValueNotifier(false);

  Future<List<Area>> fetchAreas() async {
    return _withFallback(
      online: () async {
        final data = await _getJson('/areas');
        return (data as List<dynamic>)
            .map((e) => Area.fromJson(e as Map<String, dynamic>))
            .toList();
      },
      offline: LocalCatalog.areas,
    );
  }

  Future<List<ClubSummary>> fetchClubsByArea(String areaId) async {
    return _withFallback(
      online: () async {
        final data = await _getJson('/areas/$areaId/clubs');
        return (data as List<dynamic>)
            .map((e) => ClubSummary.fromJson(e as Map<String, dynamic>))
            .toList();
      },
      offline: () => LocalCatalog.clubsByArea(areaId),
    );
  }

  Future<ClubDetail> fetchClub(String clubId) async {
    return _withFallback(
      online: () async {
        final data = await _getJson('/clubs/$clubId');
        return ClubDetail.fromJson(data as Map<String, dynamic>);
      },
      offline: () => LocalCatalog.clubById(clubId),
    );
  }

  Future<T> _withFallback<T>({
    required Future<T> Function() online,
    required Future<T> Function() offline,
  }) async {
    try {
      final result = await online();
      usingOfflineData.value = false;
      return result;
    } catch (_) {
      final result = await offline();
      usingOfflineData.value = true;
      return result;
    }
  }

  Future<dynamic> _getJson(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.get(uri).timeout(const Duration(seconds: 3));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw ApiException('Erro ${response.statusCode} ao acessar $path');
  }
}
