class EscalaMetadata {
  final String id;
  final String nombre;
  final String categoria;
  final String ruta;

  EscalaMetadata({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.ruta,
  });

  //! MODELO EscalaMetadata

  factory EscalaMetadata.fromJson(Map<String, dynamic> json) {
    return EscalaMetadata(
      id: json['id'],
      nombre: json['nombre'],
      categoria: json['categoria'],
      ruta: json['ruta'],
    );
  }
}
