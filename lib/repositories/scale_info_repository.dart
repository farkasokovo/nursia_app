import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/scale_info_model.dart';

class ScaleInfoRepository {
  static Map<String, dynamic>? _cache;

  static Future<void> loadData() async {
    if (_cache != null) return;

    final jsonString = await rootBundle.loadString(
      'assets/data/scales_data.json',
    );

    _cache = json.decode(jsonString);
  }

  static Future<ScaleInfoModel> getScale(String scaleId) async {
    await loadData();

    final scaleJson = _cache![scaleId];

    return ScaleInfoModel.fromJson(scaleJson);
  }
}
