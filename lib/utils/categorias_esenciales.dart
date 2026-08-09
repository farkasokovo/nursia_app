import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Una de las 4 categorías del módulo Esenciales.
///
/// Este archivo es la ÚNICA fuente de verdad de la taxonomía del módulo: el
/// nombre visible, el ícono y la descripción de cada categoría se definen aquí
/// y todo lo demás los lee de aquí (pestañas, botones de la pestaña casa,
/// chips de resultados y la tarjeta "Acerca de Esenciales"). Cambiar un ícono
/// = cambiar un renglón, en un solo lugar.
///
/// Ojo: esto NO es lo mismo que `esencial_icon_mapper.dart`. Aquel mapea el
/// campo `icono` de CADA FICHA (una lista abierta que crece con el contenido);
/// esto describe las 4 categorías, que son un conjunto fijo.
class CategoriaEsencial {
  /// Valor del campo `categoria` en el JSON/SQLite.
  final String clave;

  /// Nombre visible para el usuario.
  final String etiqueta;

  final IconData icono;

  /// Qué encontrará el usuario ahí (se usa en "Acerca de Esenciales").
  final String descripcion;

  /// Pestaña que le toca en EsencialesScreen. El índice 2 es la pestaña casa,
  /// por eso ninguna categoría lo usa.
  final int tabIndex;

  const CategoriaEsencial({
    required this.clave,
    required this.etiqueta,
    required this.icono,
    required this.descripcion,
    required this.tabIndex,
  });
}

const List<CategoriaEsencial> categoriasEsenciales = [
  CategoriaEsencial(
    clave: 'insumos',
    etiqueta: 'Insumos',
    icono: PhosphorIconsFill.testTube,
    descripcion: 'calibres, medidas y material de uso diario.',
    tabIndex: 0,
  ),
  CategoriaEsencial(
    clave: 'paciente',
    etiqueta: 'Paciente',
    icono: PhosphorIconsFill.person,
    descripcion: 'valores de referencia y datos por edad.',
    tabIndex: 1,
  ),
  CategoriaEsencial(
    clave: 'equipo',
    etiqueta: 'Equipo',
    icono: PhosphorIconsFill.pulse,
    descripcion: 'manejo y parámetros del equipo de la unidad.',
    tabIndex: 3,
  ),
  CategoriaEsencial(
    clave: 'codigos',
    etiqueta: 'Códigos',
    icono: PhosphorIconsFill.firstAid,
    descripcion: 'colores, claves y señalización.',
    tabIndex: 4,
  ),
];

/// Busca por el valor del campo `categoria`. Devuelve null si el JSON trae una
/// clave que no existe (error de dedo), para que quien llame decida el
/// respaldo en vez de crashear.
CategoriaEsencial? categoriaPorClave(String clave) {
  for (final categoria in categoriasEsenciales) {
    if (categoria.clave == clave) return categoria;
  }
  return null;
}

/// Devuelve la categoría de una pestaña. Null en el índice 2 (pestaña casa).
CategoriaEsencial? categoriaPorTab(int tabIndex) {
  for (final categoria in categoriasEsenciales) {
    if (categoria.tabIndex == tabIndex) return categoria;
  }
  return null;
}
