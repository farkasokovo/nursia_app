// lib/models/medicamento.dart
class Medicamento {
  final String nombre;
  final String presentacion;
  final String via;
  final String dosisAdulto;
  final String dosisPediatrica;
  final String maximoDiario;
  final String contraindicaciones;
  final String interacciones;
  final String indicaciones;
  final String icono;
  final String categoria; // 👈 NUEVO

  const Medicamento({
    required this.nombre,
    required this.presentacion,
    required this.via,
    required this.dosisAdulto,
    required this.dosisPediatrica,
    required this.maximoDiario,
    required this.contraindicaciones,
    required this.interacciones,
    required this.indicaciones,
    required this.icono,
    required this.categoria, // 👈 NUEVO
  });

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      nombre: json['nombre'] ?? '',
      presentacion: json['presentacion'] ?? '',
      via: json['via'] ?? '',
      dosisAdulto: json['dosisAdulto'] ?? '',
      dosisPediatrica: json['dosisPediatrica'] ?? '',
      maximoDiario: json['maximoDiario'] ?? '',
      contraindicaciones: json['contraindicaciones'] ?? '',
      interacciones: json['interacciones'] ?? '',
      indicaciones: json['indicaciones'] ?? '',
      icono: json['icono'] ?? 'pill',
      categoria:
          json['categoria'] ?? 'general', // 👈 NUEVO con valor por defecto
    );
  }
}
