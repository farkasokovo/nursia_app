import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/ver_mas_screen.dart';

class RepositorioEscalas {
  static Map<String, dynamic>? _cache;

  static Future<void> loadData() async {
    if (_cache != null) return;

    final jsonString = await rootBundle.loadString(
      'assets/data/scales_data.json',
    );

    _cache = json.decode(jsonString);
  }

  static Future<VerMasScreen> getScale(String scaleId) async {
    await loadData();

    final scaleJson = _cache![scaleId];

    return VerMasScreen.fromJson(scaleJson);
  }
}
