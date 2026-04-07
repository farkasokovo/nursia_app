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

  // Convierte un registro de la DB de vuelta a Objeto
  factory EscalaMetadata.fromMap(Map<String, dynamic> map) {
    return EscalaMetadata(
      id: map['id'],
      nombre: map['nombre'],
      categoria: map['categoria'],
      ruta: map['ruta'],
    );
  }

  // Prepara el objeto para ser guardado en la DB
  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre, 'categoria': categoria, 'ruta': ruta};
  }

  // Mantenemos tu fromJson por si lo necesitas para la migración inicial
  factory EscalaMetadata.fromJson(Map<String, dynamic> json) {
    return EscalaMetadata(
      id: json['id'],
      nombre: json['nombre'],
      categoria: json['categoria'],
      ruta: json['ruta'],
    );
  }
}
