import 'dart:convert';

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
  final Observaciones? observaciones;
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
    this.observaciones,
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
      observaciones: json['observaciones'] != null
          ? Observaciones.fromJson(json['observaciones'])
          : null,
      referencias:
          (json['referencias'] as List?)
              ?.map((e) => Referencia.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'icono': icono,
      'categoria': categoria,
      'farmacodinamia': farmacodinamia,
      'farmacocinetica': farmacocinetica,
      'indicaciones': indicaciones,
      'viaAdministracion': viaAdministracion,
      'contraindicaciones': jsonEncode(contraindicaciones.toJson()),
      'efectosSecundarios': jsonEncode(efectosSecundarios),
      'efectosAdversos': jsonEncode(efectosAdversos),
      'interacciones': jsonEncode(
        interacciones.map((i) => i.toJson()).toList(),
      ),
      'observaciones': observaciones != null
          ? jsonEncode(observaciones!.toJson())
          : null,
      'referencias': jsonEncode(referencias.map((r) => r.toJson()).toList()),
    };
  }

  factory Medicamento.fromMap(Map<String, dynamic> map) {
    return Medicamento(
      nombre: map['nombre'],
      icono: map['icono'],
      categoria: map['categoria'],
      farmacodinamia: map['farmacodinamia'],
      farmacocinetica: map['farmacocinetica'],
      indicaciones: map['indicaciones'],
      viaAdministracion: map['viaAdministracion'],
      contraindicaciones: Contraindicaciones.fromJson(
        jsonDecode(map['contraindicaciones']),
      ),
      efectosSecundarios: List<String>.from(
        jsonDecode(map['efectosSecundarios']),
      ),
      efectosAdversos: List<String>.from(jsonDecode(map['efectosAdversos'])),
      interacciones: (jsonDecode(map['interacciones'] ?? '[]') as List)
          .map((e) => Interaccion.fromJson(e))
          .toList(),
      // 👇 NUEVO: deserializar observaciones desde SQLite
      observaciones: map['observaciones'] != null
          ? Observaciones.fromJson(jsonDecode(map['observaciones']))
          : null,
      referencias: (jsonDecode(map['referencias'] ?? '[]') as List)
          .map((e) => Referencia.fromJson(e))
          .toList(),
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

  Map<String, dynamic> toJson() => {
    'absolutas': absolutas,
    'relativas': relativas,
  };
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

  Map<String, dynamic> toJson() => {
    'medicamento': medicamento,
    'efecto': efecto,
    'severidad': severidad,
  };
}

class Referencia {
  final String text;
  final String url;

  Referencia({required this.text, required this.url});

  factory Referencia.fromJson(Map<String, dynamic> json) {
    return Referencia(text: json['text'] ?? '', url: json['url'] ?? '');
  }

  Map<String, dynamic> toJson() => {'text': text, 'url': url};
}

class Observaciones {
  final String? preparacion;
  final String? administracion;
  final String? precauciones;

  Observaciones({this.preparacion, this.administracion, this.precauciones});

  factory Observaciones.fromJson(Map<String, dynamic> json) {
    return Observaciones(
      preparacion: json['preparacion'],
      administracion: json['administracion'],
      precauciones: json['precauciones'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (preparacion != null) 'preparacion': preparacion,
    if (administracion != null) 'administracion': administracion,
    if (precauciones != null) 'precauciones': precauciones,
  };
}
