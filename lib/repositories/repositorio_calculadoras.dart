// lib/repositories/repositorio_calculadoras.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/calculadora_info.dart';

class RepositorioCalculadoras {
  static Map<String, CalculadoraInfo>? _cache;

  static Future<void> _loadData() async {
    if (_cache != null) return;
    final jsonString = await rootBundle.loadString(
      'assets/data/calculadoras_info.json',
    );
    final Map<String, dynamic> data = json.decode(jsonString);
    final List<dynamic> lista = data['calculadoras'];
    _cache = {
      for (var item in lista) item['id']: CalculadoraInfo.fromJson(item),
    };
  }

  static Future<CalculadoraInfo> getInfo(String id) async {
    await _loadData();
    return _cache![id]!;
  }
}
