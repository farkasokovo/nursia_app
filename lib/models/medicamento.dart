class Medicamento {
  final String nombre;
  final String icono;
  final String categoria;
  final String farmacodinamia;
  final String farmacocinetica;
  final String indicaciones;
  final String viaAdministracion;
  final Contraindicaciones contraindicaciones;
  final List<String> efectosSecundarios;
  final List<String> efectosAdversos;
  final List<Interaccion> interacciones;
  final List<Referencia> referencias;

  const Medicamento({
    required this.nombre,
    required this.icono,
    required this.categoria,
    required this.farmacodinamia,
    required this.farmacocinetica,
    required this.indicaciones,
    required this.viaAdministracion,
    required this.contraindicaciones,
    required this.efectosSecundarios,
    required this.efectosAdversos,
    required this.interacciones,
    required this.referencias,
  });

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      nombre: json['nombre'] ?? '',
      icono: json['icono'] ?? 'pill',
      categoria: json['categoria'] ?? 'general',
      farmacodinamia: json['farmacodinamia'] ?? '',
      farmacocinetica: json['farmacocinetica'] ?? '',
      indicaciones: json['indicaciones'] ?? '',
      viaAdministracion: json['viaAdministracion'] ?? '',
      contraindicaciones: Contraindicaciones.fromJson(
        json['contraindicaciones'] ?? {},
      ),
      efectosSecundarios: List<String>.from(json['efectosSecundarios'] ?? []),
      efectosAdversos: List<String>.from(json['efectosAdversos'] ?? []),
      interacciones:
          (json['interacciones'] as List?)
              ?.map((e) => Interaccion.fromJson(e))
              .toList() ??
          [],
      referencias:
          (json['referencias'] as List?)
              ?.map((e) => Referencia.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Contraindicaciones {
  final List<String> absolutas;
  final List<String> relativas;

  Contraindicaciones({required this.absolutas, required this.relativas});

  factory Contraindicaciones.fromJson(Map<String, dynamic> json) {
    return Contraindicaciones(
      absolutas: List<String>.from(json['absolutas'] ?? []),
      relativas: List<String>.from(json['relativas'] ?? []),
    );
  }
}

class Interaccion {
  final String medicamento;
  final String efecto;
  final String severidad;

  Interaccion({
    required this.medicamento,
    required this.efecto,
    required this.severidad,
  });

  factory Interaccion.fromJson(Map<String, dynamic> json) {
    return Interaccion(
      medicamento: json['medicamento'] ?? '',
      efecto: json['efecto'] ?? '',
      severidad: json['severidad'] ?? '',
    );
  }
}

class Referencia {
  final String text;
  final String url;

  Referencia({required this.text, required this.url});

  factory Referencia.fromJson(Map<String, dynamic> json) {
    return Referencia(text: json['text'] ?? '', url: json['url'] ?? '');
  }
}
