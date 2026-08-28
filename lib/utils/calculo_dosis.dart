// lib/utils/calculo_dosis.dart
//
// Única fuente de verdad para las conversiones de masa (mcg / mg / g) y para
// el cálculo de la regla de tres de la calculadora de dosis.
//
// La lógica vive aquí, fuera del State del widget, por dos razones:
//  1. Es una calculadora clínica: un error de factor 1000 entre mcg y mg puede
//     dañar a un paciente, así que la lógica tiene que ser verificable con
//     pruebas unitarias (`test/calculadora_dosis_test.dart`).
//  2. La pestaña "Cálculo" y la pestaña "Conversor" deben convertir EXACTAMENTE
//     igual. Si cada una tuviera su propia conversión, podrían divergir.

import 'dart:math' as math;

// ================== ENUM DE UNIDADES ==================
enum UnidadDosis { mcg, mg, g }

extension UnidadDosisExtension on UnidadDosis {
  String get label {
    switch (this) {
      case UnidadDosis.mcg:
        return 'mcg';
      case UnidadDosis.mg:
        return 'mg';
      case UnidadDosis.g:
        return 'g';
    }
  }

  /// Convierte el valor ingresado a mg (unidad interna de todos los cálculos).
  double toMg(double valor) {
    switch (this) {
      case UnidadDosis.mcg:
        return valor / 1000.0;
      case UnidadDosis.mg:
        return valor;
      case UnidadDosis.g:
        return valor * 1000.0;
    }
  }

  /// Inversa exacta de [toMg]: pasa un valor en mg a esta unidad.
  double desdeMg(double mg) {
    switch (this) {
      case UnidadDosis.mcg:
        return mg * 1000.0;
      case UnidadDosis.mg:
        return mg;
      case UnidadDosis.g:
        return mg / 1000.0;
    }
  }
}

/// Convierte [valor] de [origen] a [destino] pasando siempre por mg.
///
/// Pasar por mg (en vez de una tabla de factores directos) mantiene una sola
/// definición de cada factor: si algún día cambia, cambia en un solo lugar.
double convertirDosis({
  required double valor,
  required UnidadDosis origen,
  required UnidadDosis destino,
}) {
  final enMg = origen.toMg(valor);
  return destino.desdeMg(enMg);
}

// ================== RESULTADO DEL CÁLCULO ==================

/// Resultado del cálculo de dosis. Es `sealed` a propósito: obliga a que todo
/// `switch` cubra los tres casos (válido, inválido, demasiado grande) y que
/// ninguno se olvide en la UI.
sealed class ResultadoDosis {
  const ResultadoDosis();
}

/// Cálculo exitoso: [ml] es la cantidad a administrar.
class DosisCalculada extends ResultadoDosis {
  const DosisCalculada(this.ml);
  final double ml;
}

/// Faltan datos, algún campo no es un número, o la presentación es cero.
class DosisInvalida extends ResultadoDosis {
  const DosisInvalida();
}

/// El resultado sale del rango razonable (>= 10000 ml).
class DosisDemasiadoGrande extends ResultadoDosis {
  const DosisDemasiadoGrande();
}

/// Regla de tres de la calculadora de dosis.
///
///   ml a administrar = (dosis indicada en mg * diluyente en ml)
///                      / (presentación del fármaco en mg)
///
/// AMBOS valores de masa se convierten a mg antes de dividir. El diluyente
/// siempre está en ml y no se convierte.
ResultadoDosis calcularDosis({
  required String dosisTexto,
  required String diluyenteTexto,
  required String presentacionTexto,
  required UnidadDosis unidadDosis,
  required UnidadDosis unidadPresentacion,
}) {
  final dosis = double.tryParse(dosisTexto.trim());
  final diluyente = double.tryParse(diluyenteTexto.trim());
  final presentacion = double.tryParse(presentacionTexto.trim());

  if (dosis == null || diluyente == null || presentacion == null) {
    return const DosisInvalida();
  }
  if (presentacion == 0) return const DosisInvalida();

  final dosisMg = unidadDosis.toMg(dosis);
  final presentacionMg = unidadPresentacion.toMg(presentacion);

  // Red de seguridad: la conversión conserva el cero, pero dividir entre cero
  // aquí daría infinito y se mostraría como un número en pantalla.
  if (presentacionMg == 0) return const DosisInvalida();

  final ml = (dosisMg * diluyente) / presentacionMg;

  if (!ml.isFinite) return const DosisInvalida();

  // Mismo límite que antes (la parte entera >= 10000). Para un valor positivo,
  // `piso(ml) >= 10000` es equivalente a `ml >= 10000`, y así se evita
  // convertir a int un double que podría salirse del rango de un int de 64 bits.
  if (ml >= 10000) return const DosisDemasiadoGrande();

  return DosisCalculada(ml);
}

// ================== FORMATO ==================

/// Formatea una cantidad para mostrarla sin notación científica y sin ceros
/// de relleno.
///
/// El conversor produce números de magnitudes muy distintas (1 mcg = 0.000001 g,
/// 1 g = 1000000 mcg). `toString()` los mostraría como `1e-6` y `1000000.0`.
/// Aquí se elige el número de decimales según la magnitud, conservando 10
/// cifras significativas: suficiente para el rango mcg-g y muy por debajo de
/// las ~16 cifras donde aparece el ruido de punto flotante (ese ruido es el que
/// haría ver `0.30000000000000004` en pantalla).
String formatearCantidad(double valor) {
  if (!valor.isFinite) return '0';
  if (valor == 0) return '0';

  final abs = valor.abs();
  final exponente = (math.log(abs) / math.ln10).floor();
  // 10 cifras significativas: 9 decimales para un número de magnitud 1.
  final decimales = (9 - exponente).clamp(0, 20).toInt();

  var texto = valor.toStringAsFixed(decimales);
  if (texto.contains('.')) {
    texto = texto.replaceFirst(RegExp(r'0+$'), '');
    texto = texto.replaceFirst(RegExp(r'\.$'), '');
  }
  return texto;
}
