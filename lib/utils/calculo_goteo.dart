// lib/utils/calculo_goteo.dart
//
// Única fuente de verdad para el cálculo del ritmo de goteo IV.
//
// La lógica vive aquí, fuera del State del widget, por la misma razón que la de
// la calculadora de dosis: es una calculadora clínica y un error de factor 60
// entre horas y minutos daría un ritmo de infusión equivocado. Fuera del widget
// se puede verificar con pruebas unitarias (`test/calculadora_goteo_test.dart`).

// ================== ENUM DE EQUIPO ==================
enum TipoEquipo { micro, normo, macro }

extension TipoEquipoExtension on TipoEquipo {
  String get label {
    switch (this) {
      case TipoEquipo.micro:
        return 'Micro';
      case TipoEquipo.normo:
        return 'Normo';
      case TipoEquipo.macro:
        return 'Macro';
    }
  }

  /// Factor de goteo del equipo (gotas por ml)
  int get factorGoteo {
    switch (this) {
      case TipoEquipo.micro:
        return 60;
      case TipoEquipo.normo:
        return 20;
      case TipoEquipo.macro:
        return 15;
    }
  }

  /// Nombre largo para el desglose del resultado
  String get nombreLargo {
    switch (this) {
      case TipoEquipo.micro:
        return 'Microgotero';
      case TipoEquipo.normo:
        return 'Normogotero';
      case TipoEquipo.macro:
        return 'Macrogotero';
    }
  }
}

// ================== ENUM DE UNIDAD DE TIEMPO ==================

/// Unidad en la que se captura el tiempo de infusión.
///
/// En la práctica hay soluciones de 100 ml o menos que se pasan en 20 o 30
/// minutos: con solo horas y sin decimales esos casos no se podían calcular.
enum UnidadTiempo { horas, minutos }

extension UnidadTiempoExtension on UnidadTiempo {
  String get label {
    switch (this) {
      case UnidadTiempo.horas:
        return 'horas';
      case UnidadTiempo.minutos:
        return 'minutos';
    }
  }

  /// Texto de ayuda del campo, acorde a la unidad elegida.
  String get textoAyuda {
    switch (this) {
      case UnidadTiempo.horas:
        return 'Horas de infusión';
      case UnidadTiempo.minutos:
        return 'Minutos de infusión';
    }
  }

  /// Pasa el tiempo capturado a minutos, la unidad interna del cálculo.
  double aMinutos(double valor) {
    switch (this) {
      case UnidadTiempo.horas:
        return valor * 60.0;
      case UnidadTiempo.minutos:
        return valor;
    }
  }
}

// ================== RESULTADO DEL CÁLCULO ==================

/// Resultado del cálculo de goteo. Es `sealed` a propósito: obliga a que todo
/// `switch` cubra los cuatro casos y que ninguno se olvide en la UI.
sealed class ResultadoGoteo {
  const ResultadoGoteo();
}

/// Cálculo exitoso: [gotasPorMinuto] ya viene redondeado.
class GoteoCalculado extends ResultadoGoteo {
  const GoteoCalculado(this.gotasPorMinuto, this.equipo);
  final int gotasPorMinuto;
  final TipoEquipo equipo;
}

/// Faltan datos, algún campo no es un número, o volumen/tiempo no son positivos.
class GoteoInvalido extends ResultadoGoteo {
  const GoteoInvalido();
}

/// El ritmo redondea a 0 gotas/min: el volumen es muy chico para ese tiempo.
class GoteoDemasiadoLento extends ResultadoGoteo {
  const GoteoDemasiadoLento();
}

/// El ritmo llega a 1000 gotas/min o más: no es un goteo contable.
class GoteoDemasiadoRapido extends ResultadoGoteo {
  const GoteoDemasiadoRapido();
}

/// Ritmo de goteo de una infusión.
///
///   gotas/min = (volumen en ml × factor de goteo del equipo)
///               ÷ tiempo en minutos
///
/// El tiempo se pasa SIEMPRE a minutos antes de dividir. Con la unidad en horas
/// esto equivale a la fórmula clásica `volumen ÷ (horas × constante)`, porque la
/// constante del equipo es 60 ÷ factor de goteo (macro 15 → 4, normo 20 → 3,
/// micro 60 → 1). Una sola forma de la fórmula evita que las dos unidades
/// puedan divergir.
ResultadoGoteo calcularGoteo({
  required String volumenTexto,
  required String tiempoTexto,
  required TipoEquipo equipo,
  required UnidadTiempo unidadTiempo,
}) {
  final volumen = double.tryParse(volumenTexto.trim());
  final tiempo = double.tryParse(tiempoTexto.trim());

  // Validación de campos base (evita también la división por cero).
  if (volumen == null || tiempo == null || volumen <= 0 || tiempo <= 0) {
    return const GoteoInvalido();
  }

  final minutos = unidadTiempo.aMinutos(tiempo);
  if (minutos <= 0) return const GoteoInvalido();

  final gotasPorMinuto = (volumen * equipo.factorGoteo) / minutos;
  if (!gotasPorMinuto.isFinite) return const GoteoInvalido();

  // 999.5 es el punto donde el redondeo ya daría 1000: se compara antes de
  // redondear para no convertir a int un double fuera de rango.
  if (gotasPorMinuto >= 999.5) return const GoteoDemasiadoRapido();

  final redondeado = gotasPorMinuto.round();
  if (redondeado <= 0) return const GoteoDemasiadoLento();

  return GoteoCalculado(redondeado, equipo);
}
