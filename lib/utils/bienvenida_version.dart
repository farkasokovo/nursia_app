// lib/utils/bienvenida_version.dart
import 'package:flutter/foundation.dart';

import 'changelog_local.dart';
import 'preferencias_app.dart';

/// Clave bajo la que se recuerda la última versión cuya bienvenida ya se vio.
const String claveBienvenidaVista = 'bienvenida_version_vista';

/// 🔧 INTERRUPTOR DE DESARROLLO: fuerza la pantalla de bienvenida en CADA
/// arranque, para poder revisar su diseño sin publicar una versión.
///
/// Cómo se usa: ponerlo en `true`, correr la app en debug (`flutter run`) y la
/// bienvenida aparece cada vez que se abre. Mientras está forzada NO escribe el
/// marcador de "versión ya vista", así que no ensucia el estado real del
/// dispositivo. **Regresarlo a `false` al terminar.**
///
/// Requiere que la versión instalada tenga su entrada en
/// `assets/data/changelog.json`; si no la tiene, no hay novedades que mostrar y
/// la pantalla no aparece.
///
/// DOBLE SEGURO para que esto no llegue nunca a un APK publicado:
///  1. Solo tiene efecto junto con `kDebugMode`, que es una constante de
///     compilación: en un build de release la condición se evalúa a false y el
///     bloque ni siquiera queda en el binario, aunque esta constante esté en
///     `true`.
///  2. `test/actualizaciones_test.dart` falla si esta constante quedó en
///     `true`, así que `flutter test` lo avisa antes de compilar el APK.
const bool forzarBienvenida = false;

/// Qué hacer con la pantalla de bienvenida en este arranque.
///
/// [mostrar] y [recordar] son independientes a propósito: hay casos en los que
/// no se muestra nada pero sí conviene anotar la versión, para no volver a
/// evaluarlo en cada arranque.
class DecisionBienvenida {
  const DecisionBienvenida({required this.mostrar, required this.recordar});

  final bool mostrar;
  final bool recordar;

  @override
  String toString() =>
      'DecisionBienvenida(mostrar: $mostrar, recordar: $recordar)';
}

/// Decide si toca mostrar la bienvenida de novedades.
///
/// Función pura, sin disco ni red, para poder probarla completa.
///
/// - Misma versión que la recordada: no se muestra (ya se vio) ni hace falta
///   volver a guardar.
/// - Sin versión recordada (instalación nueva): NO se muestra. A quien abre la
///   app por primera vez, "novedades" no le dice nada; lo primero que debe ver
///   es la app. Se recuerda la versión para que la siguiente actualización sí
///   la muestre.
/// - Versión distinta y sin notas en el changelog: no se muestra una pantalla
///   vacía, pero sí se recuerda, para no reintentarlo en cada arranque.
/// - Versión distinta y con notas: se muestra y se recuerda.
DecisionBienvenida decidirBienvenida({
  required String versionInstalada,
  required String? versionRecordada,
  required bool hayNotas,
}) {
  if (versionRecordada == versionInstalada) {
    return const DecisionBienvenida(mostrar: false, recordar: false);
  }
  if (versionRecordada == null) {
    return const DecisionBienvenida(mostrar: false, recordar: true);
  }
  if (!hayNotas) {
    return const DecisionBienvenida(mostrar: false, recordar: true);
  }
  return const DecisionBienvenida(mostrar: true, recordar: true);
}

/// Resuelve la decisión contra el disco y el changelog, y deja la versión ya
/// anotada cuando corresponde.
///
/// Devuelve true si la pantalla de bienvenida debe abrirse. Ningún fallo de
/// disco impide que la app arranque: en el peor caso devuelve false.
Future<bool> debeMostrarBienvenida({
  required String versionInstalada,
  required AlmacenPreferencias almacen,
  // Por defecto toma la constante; el parámetro existe para que las pruebas
  // puedan ejercitar el camino forzado sin dejar el interruptor encendido.
  bool forzar = forzarBienvenida,
}) async {
  // Interruptor de desarrollo. La condición con kDebugMode se resuelve en
  // tiempo de compilación: en release este bloque no existe.
  if (forzar && kDebugMode) {
    debugPrint(
      'Bienvenida: FORZADA por el interruptor de desarrollo. '
      'No se guarda el marcador. Regresar forzarBienvenida a false.',
    );
    return true;
  }

  final recordada = await almacen.leer(claveBienvenidaVista);
  final notas = await ChangelogLocal.notasDe(versionInstalada);

  final decision = decidirBienvenida(
    versionInstalada: versionInstalada,
    versionRecordada: recordada,
    hayNotas: notas != null,
  );
  debugPrint(
    'Bienvenida: instalada $versionInstalada, recordada $recordada -> $decision',
  );

  if (decision.recordar) {
    await almacen.guardar(claveBienvenidaVista, versionInstalada);
  }
  return decision.mostrar;
}
