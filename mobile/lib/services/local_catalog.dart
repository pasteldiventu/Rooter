import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/models.dart';

/// Catálogo embutido no APK (mesmos dados do backend) para demo offline.
class LocalCatalog {
  LocalCatalog._();

  static const assetPath = 'assets/data/clubs.json';

  static Map<String, dynamic>? _raw;

  static Future<Map<String, dynamic>> _load() async {
    if (_raw != null) return _raw!;
    final text = await rootBundle.loadString(assetPath);
    _raw = jsonDecode(text) as Map<String, dynamic>;
    return _raw!;
  }

  static Future<List<Area>> areas() async {
    final data = await _load();
    return (data['areas'] as List<dynamic>)
        .map((e) => Area.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<ClubSummary>> clubsByArea(String areaId) async {
    final data = await _load();
    return (data['clubs'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .where((e) => e['area_id'] == areaId)
        .map(ClubSummary.fromJson)
        .toList();
  }

  static Future<ClubDetail> clubById(String clubId) async {
    final data = await _load();
    for (final raw in data['clubs'] as List<dynamic>) {
      final club = raw as Map<String, dynamic>;
      if (club['id'] == clubId) {
        return ClubDetail.fromJson(club);
      }
    }
    throw StateError('Clube $clubId não encontrado nos dados locais');
  }
}
