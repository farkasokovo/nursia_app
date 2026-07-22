import 'dart:convert';

/// Un punto clave de una norma: un ícono alusivo + su texto.
class PuntoClave {
  final String icono;
  final String texto;

  const PuntoClave({required this.icono, required this.texto});

  factory PuntoClave.fromJson(Map<String, dynamic> json) => PuntoClave(
    icono: json['icono'] ?? '',
    texto: json['texto'] ?? '',
  );

  Map<String, dynamic> toJson() => {'icono': icono, 'texto': texto};
}

class Norma {
  final int? id;
  final String codigo;
  final String titulo;
  final String tituloCorto;
  final String areaSalud;
  final String resumen;
  final String palabrasClave;
  final List<PuntoClave> puntosClave;
  final String dofReferencia;

  Norma({
    this.id,
    required this.codigo,
    required this.titulo,
    required this.tituloCorto,
    required this.areaSalud,
    required this.resumen,
    required this.palabrasClave,
    required this.puntosClave,
    required this.dofReferencia,
  });

  // Desde el JSON semilla (assets): puntos_clave es una lista real de objetos.
  factory Norma.fromJson(Map<String, dynamic> json) => Norma(
    id: json['id'],
    codigo: json['codigo'],
    titulo: json['titulo'],
    tituloCorto: json['titulo_corto'],
    areaSalud: json['area_salud'],
    resumen: json['resumen'],
    palabrasClave: json['palabras_clave'],
    puntosClave:
        (json['puntos_clave'] as List?)
            ?.map((e) => PuntoClave.fromJson(e))
            .toList() ??
        [],
    dofReferencia: json['dof_referencia'],
  );

  // Desde SQLite: puntos_clave viene como un String con JSON adentro (la
  // columna es TEXT), así que hay que decodificarlo antes de mapear.
  factory Norma.fromMap(Map<String, dynamic> map) => Norma(
    id: map['id'],
    codigo: map['codigo'],
    titulo: map['titulo'],
    tituloCorto: map['titulo_corto'],
    areaSalud: map['area_salud'],
    resumen: map['resumen'],
    palabrasClave: map['palabras_clave'],
    puntosClave: (jsonDecode(map['puntos_clave'] ?? '[]') as List)
        .map((e) => PuntoClave.fromJson(e))
        .toList(),
    dofReferencia: map['dof_referencia'],
  );

  // Para guardar en SQLite: la lista de puntos se serializa a JSON en TEXT.
  Map<String, dynamic> toMap() => {
    'codigo': codigo,
    'titulo': titulo,
    'titulo_corto': tituloCorto,
    'area_salud': areaSalud,
    'resumen': resumen,
    'palabras_clave': palabrasClave,
    'puntos_clave': jsonEncode(puntosClave.map((p) => p.toJson()).toList()),
    'dof_referencia': dofReferencia,
  };
}
