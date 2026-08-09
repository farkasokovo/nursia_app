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
  final Dilucion? dilucion;
  final List<Referencia> referencias;
  final bool altoRiesgo;

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
    this.dilucion,
    required this.referencias,
    this.altoRiesgo = false,
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
      dilucion: json['dilucion'] != null
          ? Dilucion.fromJson(json['dilucion'])
          : null,
      referencias:
          (json['referencias'] as List?)
              ?.map((e) => Referencia.fromJson(e))
              .toList() ??
          [],
      altoRiesgo: json['altoRiesgo'] ?? false,
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
      'dilucion': dilucion != null ? jsonEncode(dilucion!.toJson()) : null,
      'referencias': jsonEncode(referencias.map((r) => r.toJson()).toList()),
      'altoRiesgo': altoRiesgo ? 1 : 0,
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
      dilucion: map['dilucion'] != null
          ? Dilucion.fromJson(jsonDecode(map['dilucion']))
          : null,
      referencias: (jsonDecode(map['referencias'] ?? '[]') as List)
          .map((e) => Referencia.fromJson(e))
          .toList(),
      altoRiesgo: (map['altoRiesgo'] ?? 0) == 1,
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

/// Información de dilución/reconstitución de un medicamento.
///
/// `verificado` indica si el contenido clínico ya fue revisado por una persona
/// contra una fuente citada. Mientras sea false, la UI muestra una franja de
/// advertencia: el dato NO debe usarse en la práctica clínica.
class Dilucion {
  /// Los cuatro estados clínicos posibles de `requiereDilucion`.
  static const String noRequiere = 'no_requiere';
  static const String noDiluir = 'no_diluir';
  static const String opcional = 'opcional';
  static const String requiere = 'requiere';

  static const List<String> valoresValidos = [
    noRequiere,
    noDiluir,
    opcional,
    requiere,
  ];

  /// Uno de [valoresValidos]. Cualquier valor desconocido se normaliza a
  /// [requiere], que es el estado más conservador: obliga a diluir.
  final String requiereDilucion;
  final bool verificado;
  final String? reconstitucion;
  final String? diluyente;
  final String? ivDirecta;
  final String? perfusionIntermitente;
  final String? perfusionContinua;
  final String? notas;
  final String? fuente;
  final String? fechaRevision;

  Dilucion({
    required this.requiereDilucion,
    this.verificado = false,
    this.reconstitucion,
    this.diluyente,
    this.ivDirecta,
    this.perfusionIntermitente,
    this.perfusionContinua,
    this.notas,
    this.fuente,
    this.fechaRevision,
  });

  /// Acepta cualquier entrada (incluidos los booleanos del esquema viejo o un
  /// null) sin lanzar excepción: lo que no sea un valor válido se trata como
  /// [requiere].
  static String normalizarRequiereDilucion(dynamic valor) {
    return valoresValidos.contains(valor) ? valor as String : requiere;
  }

  factory Dilucion.fromJson(Map<String, dynamic> json) {
    return Dilucion(
      requiereDilucion: normalizarRequiereDilucion(json['requiereDilucion']),
      verificado: json['verificado'] ?? false,
      reconstitucion: json['reconstitucion'],
      diluyente: json['diluyente'],
      ivDirecta: json['ivDirecta'],
      perfusionIntermitente: json['perfusionIntermitente'],
      perfusionContinua: json['perfusionContinua'],
      notas: json['notas'],
      fuente: json['fuente'],
      fechaRevision: json['fechaRevision'],
    );
  }

  Map<String, dynamic> toJson() => {
    'requiereDilucion': requiereDilucion,
    'verificado': verificado,
    if (reconstitucion != null) 'reconstitucion': reconstitucion,
    if (diluyente != null) 'diluyente': diluyente,
    if (ivDirecta != null) 'ivDirecta': ivDirecta,
    if (perfusionIntermitente != null)
      'perfusionIntermitente': perfusionIntermitente,
    if (perfusionContinua != null) 'perfusionContinua': perfusionContinua,
    if (notas != null) 'notas': notas,
    if (fuente != null) 'fuente': fuente,
    if (fechaRevision != null) 'fechaRevision': fechaRevision,
  };
}
