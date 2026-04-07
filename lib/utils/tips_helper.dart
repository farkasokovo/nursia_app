import 'dart:convert';
import 'package:flutter/services.dart';

class TipsHelper {
  static List<String>? _tipsCache;

  static Future<List<String>> cargarTips() async {
    if (_tipsCache != null) return _tipsCache!;
    final jsonString = await rootBundle.loadString('assets/data/tips.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _tipsCache = jsonList.map((e) => e.toString()).toList();
    return _tipsCache!;
  }

  static Future<String> obtenerTipAleatorio() async {
    final tips = await cargarTips();
    final randomIndex = DateTime.now().millisecondsSinceEpoch % tips.length;
    return tips[randomIndex];
  }
}
