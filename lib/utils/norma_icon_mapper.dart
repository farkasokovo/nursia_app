import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Mapea el nombre (String) del ícono de cada punto clave de una norma
/// a su [IconData] de Phosphor (estilo Fill).
///
/// Es a prueba de crashes: si el JSON trae un nombre que no está mapeado,
/// devuelve [PhosphorIconsFill.caretRight] (el ícono histórico de la ficha),
/// así la ficha degrada al look anterior en vez de tronar.
class NormaIconMapper {
  static const Map<String, IconData> _iconos = {
    'gavel': PhosphorIconsFill.gavel,
    'usersThree': PhosphorIconsFill.usersThree,
    'handHeart': PhosphorIconsFill.handHeart,
    'stethoscope': PhosphorIconsFill.stethoscope,
    'certificate': PhosphorIconsFill.certificate,
    'graduationCap': PhosphorIconsFill.graduationCap,
    'star': PhosphorIconsFill.star,
    'chalkboardTeacher': PhosphorIconsFill.chalkboardTeacher,
    'flask': PhosphorIconsFill.flask,
    'arrowsDownUp': PhosphorIconsFill.arrowsDownUp,
    'sealCheck': PhosphorIconsFill.sealCheck,
    'medal': PhosphorIconsFill.medal,
    'student': PhosphorIconsFill.student,
    'prohibit': PhosphorIconsFill.prohibit,
    'wrench': PhosphorIconsFill.wrench,
    'listChecks': PhosphorIconsFill.listChecks,
    'clipboardText': PhosphorIconsFill.clipboardText,
    'eye': PhosphorIconsFill.eye,
    // NOM-022 (terapia de infusión)
    'syringe': PhosphorIconsFill.syringe,
    'handSoap': PhosphorIconsFill.handSoap,
    'shieldCheck': PhosphorIconsFill.shieldCheck,
    'mapPin': PhosphorIconsFill.mapPin,
    'bandaids': PhosphorIconsFill.bandaids,
    'tag': PhosphorIconsFill.tag,
    'notePencil': PhosphorIconsFill.notePencil,
    'xCircle': PhosphorIconsFill.xCircle,
    'trash': PhosphorIconsFill.trash,
    // NOM-087 (RPBI)
    'virus': PhosphorIconsFill.virus,
    'drop': PhosphorIconsFill.drop,
    'testTube': PhosphorIconsFill.testTube,
    'dna': PhosphorIconsFill.dna,
    'biohazard': PhosphorIconsFill.biohazard,
    'arrowsSplit': PhosphorIconsFill.arrowsSplit,
    'percent': PhosphorIconsFill.percent,
    'warehouse': PhosphorIconsFill.warehouse,
    'truck': PhosphorIconsFill.truck,
  };

  /// Ícono por defecto cuando el nombre no existe en el mapa.
  static const IconData _porDefecto = PhosphorIconsFill.caretRight;

  static IconData fromString(String nombre) => _iconos[nombre] ?? _porDefecto;
}
