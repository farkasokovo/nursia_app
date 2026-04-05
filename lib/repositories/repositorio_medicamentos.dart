import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/medicamento.dart';

class RepositorioMedicamentos {
  static List<Medicamento>? _cache;

  /// Carga todos los medicamentos desde el JSON (con caché)
  static Future<List<Medicamento>> cargarMedicamentos() async {
    if (_cache != null) return _cache!;

    final jsonString = await rootBundle.loadString(
      'assets/data/medicamentos.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);

    _cache = jsonList.map((json) => Medicamento.fromJson(json)).toList();
    return _cache!;
  }

  /// Obtiene un medicamento por su nombre exacto
  static Future<Medicamento?> obtenerPorNombre(String nombre) async {
    final lista = await cargarMedicamentos();
    try {
      return lista.firstWhere((med) => med.nombre == nombre);
    } catch (e) {
      return null;
    }
  }
}
