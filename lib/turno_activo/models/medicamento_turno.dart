class MedicamentoTurno {
  final int? id;
  final String nombre;
  final String icono;
  final int orden;

  const MedicamentoTurno({
    this.id,
    required this.nombre,
    required this.icono,
    this.orden = 0,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'nombre': nombre,
    'icono': icono,
    'orden': orden,
  };

  factory MedicamentoTurno.fromMap(Map<String, dynamic> map) =>
      MedicamentoTurno(
        id: map['id'] as int?,
        nombre: map['nombre'] as String,
        icono: map['icono'] as String,
        orden: map['orden'] as int? ?? 0,
      );

  MedicamentoTurno copyWith({
    int? id,
    String? nombre,
    String? icono,
    int? orden,
  }) => MedicamentoTurno(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    icono: icono ?? this.icono,
    orden: orden ?? this.orden,
  );
}
