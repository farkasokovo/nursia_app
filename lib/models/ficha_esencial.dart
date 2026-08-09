import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Estilo de viñeta de un [BloqueLista].
///
/// Es un enum y no un String para que la pantalla de ficha pueda hacer un
/// `switch` exhaustivo sin tener que validar otra vez el texto que venga del
/// JSON. El parseo (ver [_estiloDesdeJson]) es el único punto donde se decide
/// qué hacer con un valor desconocido.
enum EstiloLista { vinetas, numerada }

/// Cualquier valor distinto de "vinetas"/"numerada" (o ausente) cae a viñetas.
EstiloLista _estiloDesdeJson(dynamic valor) {
  if (valor == 'numerada') return EstiloLista.numerada;
  if (valor != null && valor != 'vinetas') {
    debugPrint(
      'Esenciales: estilo de lista desconocido "$valor", uso viñetas.',
    );
  }
  return EstiloLista.vinetas;
}

/// Un color de una paleta de referencia (bolsas RPBI, triage, etc.).
///
/// [color] se guarda como el hex string tal cual viene del JSON ("#RRGGBB").
/// Convertirlo a `Color` es responsabilidad de la UI, no del modelo.
class ItemColor {
  final String color;
  final String etiqueta;
  final String? descripcion;

  const ItemColor({
    required this.color,
    required this.etiqueta,
    this.descripcion,
  });

  Map<String, dynamic> toJson() => {
    'color': color,
    'etiqueta': etiqueta,
    if (descripcion != null) 'descripcion': descripcion,
  };
}

/// Un bloque del contenido de una [FichaEsencial].
///
/// Es una `sealed class`: la lista de subtipos está cerrada, así que la
/// pantalla de ficha puede hacer un `switch` sobre un bloque y el compilador
/// avisa si se olvida manejar alguno.
///
/// [titulo] es opcional y funciona como subtítulo dentro de la ficha — es lo
/// que distingue, por ejemplo, dos tablas seguidas en la misma ficha.
sealed class BloqueContenido {
  final String? titulo;

  const BloqueContenido({this.titulo});

  Map<String, dynamic> toJson();
}

/// Un párrafo de texto corrido.
class BloqueTexto extends BloqueContenido {
  final String valor;

  const BloqueTexto({super.titulo, required this.valor});

  @override
  Map<String, dynamic> toJson() => {
    'tipo': 'texto',
    if (titulo != null) 'titulo': titulo,
    'valor': valor,
  };
}

/// Texto destacado (advertencia, recordatorio). Mismo dato que [BloqueTexto],
/// tipo distinto porque la UI lo dibuja diferente.
class BloqueNota extends BloqueContenido {
  final String valor;

  const BloqueNota({super.titulo, required this.valor});

  @override
  Map<String, dynamic> toJson() => {
    'tipo': 'nota',
    if (titulo != null) 'titulo': titulo,
    'valor': valor,
  };
}

/// Lista de puntos, con viñetas o numerada.
class BloqueLista extends BloqueContenido {
  final EstiloLista estilo;
  final List<String> items;

  const BloqueLista({
    super.titulo,
    this.estilo = EstiloLista.vinetas,
    required this.items,
  });

  @override
  Map<String, dynamic> toJson() => {
    'tipo': 'lista',
    if (titulo != null) 'titulo': titulo,
    // El nombre del enum coincide a propósito con el valor del JSON.
    'estilo': estilo.name,
    'items': items,
  };
}

/// Tabla simple. Todas las filas tienen tantas celdas como [encabezados]
/// (el parseo descarta las que no cuadren).
class BloqueTabla extends BloqueContenido {
  final List<String> encabezados;
  final List<List<String>> filas;

  const BloqueTabla({
    super.titulo,
    required this.encabezados,
    required this.filas,
  });

  @override
  Map<String, dynamic> toJson() => {
    'tipo': 'tabla',
    if (titulo != null) 'titulo': titulo,
    'encabezados': encabezados,
    'filas': filas,
  };
}

/// Paleta de colores con su significado.
class BloqueColores extends BloqueContenido {
  final List<ItemColor> items;

  const BloqueColores({super.titulo, required this.items});

  @override
  Map<String, dynamic> toJson() => {
    'tipo': 'colores',
    if (titulo != null) 'titulo': titulo,
    'items': items.map((i) => i.toJson()).toList(),
  };
}

/// Una referencia bibliográfica. Mismo contrato que `Referencia` en
/// `models/medicamento.dart` (campos texto + url), pero con el nombre del
/// campo en español para ir con el resto del módulo.
///
/// [url] es opcional: una referencia puede ser un libro impreso sin liga.
class ItemReferencia {
  final String texto;
  final String? url;

  const ItemReferencia({required this.texto, this.url});

  Map<String, dynamic> toJson() => {
    'texto': texto,
    if (url != null) 'url': url,
  };
}

/// Lista de referencias al final de la ficha. Las que traen [ItemReferencia.url]
/// se abren en el navegador; las demás son texto plano.
class BloqueReferencias extends BloqueContenido {
  final List<ItemReferencia> items;

  const BloqueReferencias({super.titulo, required this.items});

  @override
  Map<String, dynamic> toJson() => {
    'tipo': 'referencias',
    if (titulo != null) 'titulo': titulo,
    'items': items.map((i) => i.toJson()).toList(),
  };
}

// ── Parseo defensivo ────────────────────────────────────────────────────
//
// El JSON semilla se edita a mano, así que un bloque con el "tipo" mal
// escrito o al que le falta un campo NO puede tumbar el arranque de la app:
// se salta ese bloque, se avisa con debugPrint() y se sigue con los demás.

/// Un hex de 6 dígitos con almohadilla: "#E30613". La UI hace int.parse sobre
/// esto, así que validarlo aquí evita una excepción al dibujar.
final RegExp _hexColor = RegExp(r'^#[0-9a-fA-F]{6}$');

/// Devuelve el String si tiene contenido; null si falta, está vacío o no es
/// un String.
String? _textoRequerido(dynamic valor) {
  if (valor is! String) return null;
  final limpio = valor.trim();
  return limpio.isEmpty ? null : limpio;
}

/// Convierte los elementos de una lista JSON a Strings, descartando los vacíos.
List<String> _listaDeTextos(dynamic valor) {
  if (valor is! List) return const [];
  return valor
      .map((e) => e is String ? e.trim() : e?.toString().trim() ?? '')
      .where((e) => e.isNotEmpty)
      .toList();
}

/// Parsea un bloque suelto. Devuelve null si el bloque es inválido.
BloqueContenido? _bloqueDesdeJson(dynamic crudo) {
  if (crudo is! Map) {
    debugPrint('Esenciales: bloque ignorado, no es un objeto: $crudo');
    return null;
  }
  final json = crudo.cast<String, dynamic>();
  final titulo = _textoRequerido(json['titulo']);
  final tipo = json['tipo'];

  switch (tipo) {
    case 'texto':
    case 'nota':
      final valor = _textoRequerido(json['valor']);
      if (valor == null) {
        debugPrint('Esenciales: bloque "$tipo" sin "valor", se omite.');
        return null;
      }
      return tipo == 'texto'
          ? BloqueTexto(titulo: titulo, valor: valor)
          : BloqueNota(titulo: titulo, valor: valor);

    case 'lista':
      final items = _listaDeTextos(json['items']);
      if (items.isEmpty) {
        debugPrint('Esenciales: bloque "lista" sin "items", se omite.');
        return null;
      }
      return BloqueLista(
        titulo: titulo,
        estilo: _estiloDesdeJson(json['estilo']),
        items: items,
      );

    case 'tabla':
      final encabezados = _listaDeTextos(json['encabezados']);
      if (encabezados.isEmpty) {
        debugPrint('Esenciales: bloque "tabla" sin "encabezados", se omite.');
        return null;
      }
      final filasCrudas = json['filas'];
      final filas = <List<String>>[];
      if (filasCrudas is List) {
        for (final fila in filasCrudas) {
          if (fila is! List) {
            debugPrint('Esenciales: fila de tabla ignorada, no es lista.');
            continue;
          }
          // Aquí no se filtran las celdas vacías: una celda en blanco es
          // legítima y quitarla desalinearía la fila con los encabezados.
          final celdas = fila.map((c) => c?.toString() ?? '').toList();
          if (celdas.length != encabezados.length) {
            debugPrint(
              'Esenciales: fila de tabla con ${celdas.length} celdas pero '
              '${encabezados.length} encabezados, se omite la fila.',
            );
            continue;
          }
          filas.add(celdas);
        }
      }
      return BloqueTabla(
        titulo: titulo,
        encabezados: encabezados,
        filas: filas,
      );

    case 'colores':
      final itemsCrudos = json['items'];
      final items = <ItemColor>[];
      if (itemsCrudos is List) {
        for (final item in itemsCrudos) {
          if (item is! Map) continue;
          final mapa = item.cast<String, dynamic>();
          final color = _textoRequerido(mapa['color']);
          final etiqueta = _textoRequerido(mapa['etiqueta']);
          if (color == null || etiqueta == null) {
            debugPrint(
              'Esenciales: color sin "color" o "etiqueta", se omite: $mapa',
            );
            continue;
          }
          if (!_hexColor.hasMatch(color)) {
            debugPrint(
              'Esenciales: color "$color" no tiene formato #RRGGBB, se omite.',
            );
            continue;
          }
          items.add(
            ItemColor(
              color: color,
              etiqueta: etiqueta,
              descripcion: _textoRequerido(mapa['descripcion']),
            ),
          );
        }
      }
      if (items.isEmpty) {
        debugPrint('Esenciales: bloque "colores" sin items válidos, se omite.');
        return null;
      }
      return BloqueColores(titulo: titulo, items: items);

    case 'referencias':
      final itemsCrudos = json['items'];
      final items = <ItemReferencia>[];
      if (itemsCrudos is List) {
        for (final item in itemsCrudos) {
          if (item is! Map) continue;
          final mapa = item.cast<String, dynamic>();
          final texto = _textoRequerido(mapa['texto']);
          if (texto == null) {
            debugPrint(
              'Esenciales: referencia sin "texto", se omite el item: $mapa',
            );
            continue;
          }
          // Sin url es válido: una referencia puede ser un libro impreso.
          items.add(
            ItemReferencia(texto: texto, url: _textoRequerido(mapa['url'])),
          );
        }
      }
      if (items.isEmpty) {
        debugPrint(
          'Esenciales: bloque "referencias" sin items válidos, se omite.',
        );
        return null;
      }
      return BloqueReferencias(titulo: titulo, items: items);

    default:
      debugPrint('Esenciales: tipo de bloque desconocido "$tipo", se omite.');
      return null;
  }
}

/// Parsea el arreglo completo de bloques, saltando los inválidos.
List<BloqueContenido> _contenidoDesdeJson(dynamic crudo) {
  if (crudo is! List) {
    debugPrint('Esenciales: "contenido" no es una lista, ficha sin bloques.');
    return const [];
  }
  final bloques = <BloqueContenido>[];
  for (final item in crudo) {
    final bloque = _bloqueDesdeJson(item);
    if (bloque != null) bloques.add(bloque);
  }
  return bloques;
}

/// Ficha de referencia rápida del módulo Esenciales.
///
/// [categoria] es una de: insumos | paciente | equipo | codigos.
/// [icono] es solo el nombre del ícono; mapearlo a un IconData es cosa de la UI.
class FichaEsencial {
  final int? id;
  final String titulo;
  final String tituloCorto;
  final String categoria;
  final String icono;
  final String resumen;
  final String palabrasClave;
  final List<BloqueContenido> contenido;
  final String fuente;
  final int orden;

  FichaEsencial({
    this.id,
    required this.titulo,
    required this.tituloCorto,
    required this.categoria,
    required this.icono,
    required this.resumen,
    required this.palabrasClave,
    required this.contenido,
    required this.fuente,
    this.orden = 0,
  });

  // Desde el JSON semilla (assets): contenido es una lista real de objetos.
  factory FichaEsencial.fromJson(Map<String, dynamic> json) => FichaEsencial(
    id: json['id'],
    titulo: json['titulo'] ?? '',
    tituloCorto: json['titulo_corto'] ?? '',
    categoria: json['categoria'] ?? '',
    icono: json['icono'] ?? '',
    resumen: json['resumen'] ?? '',
    palabrasClave: json['palabras_clave'] ?? '',
    contenido: _contenidoDesdeJson(json['contenido']),
    fuente: json['fuente'] ?? '',
    orden: json['orden'] ?? 0,
  );

  // Desde SQLite: contenido viene como un String con JSON adentro (la columna
  // es TEXT), así que hay que decodificarlo antes de mapear.
  factory FichaEsencial.fromMap(Map<String, dynamic> map) => FichaEsencial(
    id: map['id'],
    titulo: map['titulo'] ?? '',
    tituloCorto: map['titulo_corto'] ?? '',
    categoria: map['categoria'] ?? '',
    icono: map['icono'] ?? '',
    resumen: map['resumen'] ?? '',
    palabrasClave: map['palabras_clave'] ?? '',
    contenido: _contenidoDesdeJson(jsonDecode(map['contenido'] ?? '[]')),
    fuente: map['fuente'] ?? '',
    orden: map['orden'] ?? 0,
  );

  // Para guardar en SQLite: la lista de bloques se serializa a JSON en TEXT.
  Map<String, dynamic> toMap() => {
    'titulo': titulo,
    'titulo_corto': tituloCorto,
    'categoria': categoria,
    'icono': icono,
    'resumen': resumen,
    'palabras_clave': palabrasClave,
    'contenido': jsonEncode(contenido.map((b) => b.toJson()).toList()),
    'fuente': fuente,
    'orden': orden,
  };
}
