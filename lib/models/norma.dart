class Norma {
  final int? id;
  final String codigo;
  final String titulo;
  final String tituloCorto;
  final String areaSalud;
  final String resumen;
  final String palabrasClave;
  final String puntosClave;
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

  // Para convertir de Mapa (SQLite/JSON) a Objeto Dart
  factory Norma.fromMap(Map<String, dynamic> json) => Norma(
    id: json['id'],
    codigo: json['codigo'],
    titulo: json['titulo'],
    tituloCorto: json['titulo_corto'],
    areaSalud: json['area_salud'],
    resumen: json['resumen'],
    palabrasClave: json['palabras_clave'],
    puntosClave: json['puntos_clave'],
    dofReferencia: json['dof_referencia'],
  );
}
