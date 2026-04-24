// ── MODELO PACIENTE ────────────────────────────────────────────────────────
// Clase escalable: agrega campos aquí cuando necesites más datos.
class Paciente {
  final int? id; // PK de SQLite, null antes de persistir
  final String nombre;
  final int orden; // Posición en la lista, para respetar el reordenamiento

  // Futuros campos:
  // final int? edad;
  // final String? diagnostico;
  // final String? cama;

  const Paciente({this.id, required this.nombre, this.orden = 0});

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'nombre': nombre,
    'orden': orden,
  };

  factory Paciente.fromMap(Map<String, dynamic> map) => Paciente(
    id: map['id'] as int?,
    nombre: map['nombre'] as String,
    orden: map['orden'] as int? ?? 0,
  );

  // Copia con campos modificados (útil para actualizar orden sin recrear)
  Paciente copyWith({int? id, String? nombre, int? orden}) => Paciente(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    orden: orden ?? this.orden,
  );
}
