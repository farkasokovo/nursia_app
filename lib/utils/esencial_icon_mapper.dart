import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Mapea el nombre (String) del campo `icono` de una [FichaEsencial] a su
/// [IconData] de Phosphor (estilo Fill).
///
/// Es a prueba de crashes: si el JSON trae un nombre que no está mapeado,
/// devuelve [PhosphorIconsFill.clipboardText], así la ficha se ve con un
/// ícono genérico en vez de tronar.
///
/// Agregar una ficha con un ícono nuevo = agregar un renglón aquí. Mientras el
/// nombre ya esté en el mapa, una ficha nueva se resuelve solo en el JSON.
class EsencialIconMapper {
  static const Map<String, IconData> _iconos = {
    // Los que ya usa assets/data/esenciales_data.json
    'syringe': PhosphorIconsFill.syringe,
    'user': PhosphorIconsFill.user,
    'wrench': PhosphorIconsFill.wrench,
    'palette': PhosphorIconsFill.palette,
    // Insumos
    'drop': PhosphorIconsFill.drop,
    'testTube': PhosphorIconsFill.testTube,
    'bandaids': PhosphorIconsFill.bandaids,
    'ruler': PhosphorIconsFill.ruler,
    'pill': PhosphorIconsFill.pill,
    // Paciente
    'heartbeat': PhosphorIconsFill.heartbeat,
    'thermometer': PhosphorIconsFill.thermometer,
    'baby': PhosphorIconsFill.baby,
    'stethoscope': PhosphorIconsFill.stethoscope,
    // Equipo
    'gauge': PhosphorIconsFill.gauge,
    'plugCharging': PhosphorIconsFill.plugCharging,
    'firstAidKit': PhosphorIconsFill.firstAidKit,
    // Códigos y señalización
    'warning': PhosphorIconsFill.warning,
    'biohazard': PhosphorIconsFill.biohazard,
    'trash': PhosphorIconsFill.trash,
    'shieldCheck': PhosphorIconsFill.shieldCheck,
    'fireExtinguisher': PhosphorIconsFill.fireExtinguisher,
    'listChecks': PhosphorIconsFill.listChecks,
  };

  /// Ícono por defecto cuando el nombre no existe en el mapa.
  static const IconData _porDefecto = PhosphorIconsFill.clipboardText;

  static IconData fromString(String nombre) => _iconos[nombre] ?? _porDefecto;
}
