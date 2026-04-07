import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class TipsHelper {
  static List<String>? _tipsCache;

  // Guardamos el tip generado manualmente en esta sesión
  static String? _tipManual;

  static Future<List<String>> cargarTips() async {
    if (_tipsCache != null) return _tipsCache!;
    final jsonString = await rootBundle.loadString('assets/data/tips.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _tipsCache = jsonList.map((e) => e.toString()).toList();
    return _tipsCache!;
  }

  static Future<String> obtenerTipPersistente() async {
    // 1. Si el usuario ya presionó el botón de "refrescar" en esta sesión,
    // seguimos mostrando ese tip manual.
    if (_tipManual != null) return _tipManual!;

    final tips = await cargarTips();
    if (tips.isEmpty) return "No hay tips disponibles";

    // 2. LÓGICA POR DÍA:
    // Creamos un número único basado en la fecha (ej: 20240520)
    final ahora = DateTime.now();
    final fechaId = ahora.year * 10000 + ahora.month * 100 + ahora.day;

    // Usamos esa fecha como "semilla". Esto garantiza que el "Random"
    // elija el MISMO tip durante las 24 horas de ese día.
    final randomDiario = Random(fechaId);
    return tips[randomDiario.nextInt(tips.length)];
  }

  static Future<String> generarNuevoTip() async {
    final tips = await cargarTips();
    if (tips.isEmpty) return "No hay tips disponibles";

    // Para el cambio manual, sí usamos un Random real sin semilla fija
    _tipManual = tips[Random().nextInt(tips.length)];
    return _tipManual!;
  }
}
