// test/calculadora_dosis_test.dart
//
// Pruebas de la lógica de la calculadora de dosis (lib/utils/calculo_dosis.dart).
//
// Es una calculadora clínica: un error de factor 1000 entre mcg y mg puede
// dañar a un paciente. Todos los resultados esperados de este archivo están
// calculados a mano y anotados en un comentario junto a cada caso; ninguno se
// obtuvo corriendo el código.

import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/utils/calculo_dosis.dart';

/// Azúcar para leer los casos: devuelve los ml de un cálculo que debe ser válido.
double mlDe(
  String dosis,
  String diluyente,
  String presentacion, {
  required UnidadDosis unidadDosis,
  required UnidadDosis unidadPresentacion,
}) {
  final resultado = calcularDosis(
    dosisTexto: dosis,
    diluyenteTexto: diluyente,
    presentacionTexto: presentacion,
    unidadDosis: unidadDosis,
    unidadPresentacion: unidadPresentacion,
  );
  expect(
    resultado,
    isA<DosisCalculada>(),
    reason:
        'Se esperaba un cálculo válido para $dosis / $diluyente / $presentacion',
  );
  return (resultado as DosisCalculada).ml;
}

ResultadoDosis calculo(
  String dosis,
  String diluyente,
  String presentacion, {
  UnidadDosis unidadDosis = UnidadDosis.mg,
  UnidadDosis unidadPresentacion = UnidadDosis.mg,
}) {
  return calcularDosis(
    dosisTexto: dosis,
    diluyenteTexto: diluyente,
    presentacionTexto: presentacion,
    unidadDosis: unidadDosis,
    unidadPresentacion: unidadPresentacion,
  );
}

void main() {
  // ================================================================
  // CONVERSIÓN DE UNIDADES
  // ================================================================
  group('toMg: conversión a la unidad interna', () {
    test('mcg a mg divide entre 1000', () {
      // 500 mcg = 0.5 mg
      expect(UnidadDosis.mcg.toMg(500), closeTo(0.5, 1e-12));
      // 1 mcg = 0.001 mg
      expect(UnidadDosis.mcg.toMg(1), closeTo(0.001, 1e-12));
    });

    test('mg a mg no cambia el valor', () {
      expect(UnidadDosis.mg.toMg(500), 500);
      expect(UnidadDosis.mg.toMg(0.25), 0.25);
    });

    test('g a mg multiplica por 1000', () {
      // 1 g = 1000 mg
      expect(UnidadDosis.g.toMg(1), 1000);
      // 0.5 g = 500 mg
      expect(UnidadDosis.g.toMg(0.5), 500);
    });

    test('el cero se conserva en cualquier unidad', () {
      for (final unidad in UnidadDosis.values) {
        expect(unidad.toMg(0), 0);
      }
    });
  });

  group('desdeMg: inversa de toMg', () {
    test('mg a mcg multiplica por 1000', () {
      // 0.5 mg = 500 mcg
      expect(UnidadDosis.mcg.desdeMg(0.5), closeTo(500, 1e-9));
    });

    test('mg a g divide entre 1000', () {
      // 2500 mg = 2.5 g
      expect(UnidadDosis.g.desdeMg(2500), closeTo(2.5, 1e-12));
    });

    test('ida y vuelta devuelve el valor original', () {
      for (final unidad in UnidadDosis.values) {
        expect(unidad.desdeMg(unidad.toMg(7.5)), closeTo(7.5, 1e-9));
      }
    });
  });

  group('convertirDosis: conversor de la tercera pestaña', () {
    test('1 g equivale a 1000000 mcg', () {
      expect(
        convertirDosis(
          valor: 1,
          origen: UnidadDosis.g,
          destino: UnidadDosis.mcg,
        ),
        closeTo(1000000, 1e-6),
      );
    });

    test('1 mcg equivale a 0.000001 g', () {
      expect(
        convertirDosis(
          valor: 1,
          origen: UnidadDosis.mcg,
          destino: UnidadDosis.g,
        ),
        closeTo(0.000001, 1e-15),
      );
    });

    test('1500 mcg equivalen a 1.5 mg', () {
      expect(
        convertirDosis(
          valor: 1500,
          origen: UnidadDosis.mcg,
          destino: UnidadDosis.mg,
        ),
        closeTo(1.5, 1e-12),
      );
    });

    test('0.5 g equivalen a 500 mg', () {
      expect(
        convertirDosis(
          valor: 0.5,
          origen: UnidadDosis.g,
          destino: UnidadDosis.mg,
        ),
        closeTo(500, 1e-12),
      );
    });

    test('2500 mg equivalen a 2.5 g', () {
      expect(
        convertirDosis(
          valor: 2500,
          origen: UnidadDosis.mg,
          destino: UnidadDosis.g,
        ),
        closeTo(2.5, 1e-12),
      );
    });

    test('convertir a la misma unidad no cambia el valor', () {
      for (final unidad in UnidadDosis.values) {
        expect(
          convertirDosis(valor: 7.5, origen: unidad, destino: unidad),
          closeTo(7.5, 1e-9),
        );
      }
    });

    test('el conversor y el cálculo usan la misma conversión', () {
      // 2 g de dosis deben dar el mismo resultado que su equivalente en mg.
      final enGramos = mlDe(
        '2',
        '10',
        '1000',
        unidadDosis: UnidadDosis.g,
        unidadPresentacion: UnidadDosis.mg,
      );
      final enMg = mlDe(
        convertirDosis(
          valor: 2,
          origen: UnidadDosis.g,
          destino: UnidadDosis.mg,
        ).toString(),
        '10',
        '1000',
        unidadDosis: UnidadDosis.mg,
        unidadPresentacion: UnidadDosis.mg,
      );
      expect(enGramos, closeTo(enMg, 1e-9));
    });
  });

  // ================================================================
  // CÁLCULO: (dosis en mg * diluyente en ml) / presentación en mg
  // ================================================================
  group('calcularDosis: ambas unidades en mg (comportamiento previo)', () {
    test('500 mg de una presentación de 1000 mg diluida en 10 ml', () {
      // (500 * 10) / 1000 = 5 ml
      expect(
        mlDe(
          '500',
          '10',
          '1000',
          unidadDosis: UnidadDosis.mg,
          unidadPresentacion: UnidadDosis.mg,
        ),
        closeTo(5.0, 1e-9),
      );
    });

    test('la dosis igual a la presentación usa todo el diluyente', () {
      // (250 * 5) / 250 = 5 ml
      expect(
        mlDe(
          '250',
          '5',
          '250',
          unidadDosis: UnidadDosis.mg,
          unidadPresentacion: UnidadDosis.mg,
        ),
        closeTo(5.0, 1e-9),
      );
    });

    test('acepta decimales en los tres campos', () {
      // (7.5 * 2.5) / 1.5 = 18.75 / 1.5 = 12.5 ml
      expect(
        mlDe(
          '7.5',
          '2.5',
          '1.5',
          unidadDosis: UnidadDosis.mg,
          unidadPresentacion: UnidadDosis.mg,
        ),
        closeTo(12.5, 1e-9),
      );
    });
  });

  group('calcularDosis: unidades distintas entre dosis y presentación', () {
    test('dosis en mcg con presentación en mg', () {
      // 500 mcg = 0.5 mg. (0.5 * 2) / 1 = 1 ml
      expect(
        mlDe(
          '500',
          '2',
          '1',
          unidadDosis: UnidadDosis.mcg,
          unidadPresentacion: UnidadDosis.mg,
        ),
        closeTo(1.0, 1e-9),
      );
    });

    test('dosis en mcg con presentación en mg (caso tipo fentanilo)', () {
      // 50 mcg = 0.05 mg. (0.05 * 10) / 0.5 = 0.5 / 0.5 = 1 ml
      expect(
        mlDe(
          '50',
          '10',
          '0.5',
          unidadDosis: UnidadDosis.mcg,
          unidadPresentacion: UnidadDosis.mg,
        ),
        closeTo(1.0, 1e-9),
      );
    });

    test('dosis en mg con presentación en mcg', () {
      // 500 mcg de presentación = 0.5 mg. (1 * 10) / 0.5 = 20 ml
      expect(
        mlDe(
          '1',
          '10',
          '500',
          unidadDosis: UnidadDosis.mg,
          unidadPresentacion: UnidadDosis.mcg,
        ),
        closeTo(20.0, 1e-9),
      );
    });

    test('dosis en g con presentación en mg', () {
      // 1 g = 1000 mg. (1000 * 10) / 500 = 20 ml
      expect(
        mlDe(
          '1',
          '10',
          '500',
          unidadDosis: UnidadDosis.g,
          unidadPresentacion: UnidadDosis.mg,
        ),
        closeTo(20.0, 1e-9),
      );
    });

    test('dosis en mg con presentación en g', () {
      // 1 g de presentación = 1000 mg. (750 * 10) / 1000 = 7.5 ml
      expect(
        mlDe(
          '750',
          '10',
          '1',
          unidadDosis: UnidadDosis.mg,
          unidadPresentacion: UnidadDosis.g,
        ),
        closeTo(7.5, 1e-9),
      );
    });

    test('dosis en g con presentación en mcg', () {
      // 0.001 g = 1 mg; 500 mcg = 0.5 mg. (1 * 2) / 0.5 = 4 ml
      expect(
        mlDe(
          '0.001',
          '2',
          '500',
          unidadDosis: UnidadDosis.g,
          unidadPresentacion: UnidadDosis.mcg,
        ),
        closeTo(4.0, 1e-9),
      );
    });

    test('dosis en mcg con presentación en g', () {
      // 2000 mcg = 2 mg; 1 g = 1000 mg. (2 * 100) / 1000 = 0.2 ml
      expect(
        mlDe(
          '2000',
          '100',
          '1',
          unidadDosis: UnidadDosis.mcg,
          unidadPresentacion: UnidadDosis.g,
        ),
        closeTo(0.2, 1e-9),
      );
    });
  });

  group('calcularDosis: ambas unidades iguales pero distintas de mg', () {
    test('ambas en g se comportan como una proporción directa', () {
      // 2 g = 2000 mg; 1 g = 1000 mg. (2000 * 10) / 1000 = 20 ml
      expect(
        mlDe(
          '2',
          '10',
          '1',
          unidadDosis: UnidadDosis.g,
          unidadPresentacion: UnidadDosis.g,
        ),
        closeTo(20.0, 1e-9),
      );
    });

    test('ambas en mcg se comportan como una proporción directa', () {
      // 250 mcg = 0.25 mg; 500 mcg = 0.5 mg. (0.25 * 4) / 0.5 = 2 ml
      expect(
        mlDe(
          '250',
          '4',
          '500',
          unidadDosis: UnidadDosis.mcg,
          unidadPresentacion: UnidadDosis.mcg,
        ),
        closeTo(2.0, 1e-9),
      );
    });

    test('la misma proporción da el mismo resultado en las tres unidades', () {
      // Mitad de la presentación en 10 ml = 5 ml, sin importar la unidad.
      for (final unidad in UnidadDosis.values) {
        expect(
          mlDe(
            '50',
            '10',
            '100',
            unidadDosis: unidad,
            unidadPresentacion: unidad,
          ),
          closeTo(5.0, 1e-9),
          reason: 'Falla con la unidad ${unidad.label}',
        );
      }
    });
  });

  // ================================================================
  // CASOS LÍMITE
  // ================================================================
  group('calcularDosis: casos límite', () {
    test('presentación en cero es inválida (no divide entre cero)', () {
      expect(calculo('500', '10', '0'), isA<DosisInvalida>());
      expect(
        calculo('500', '10', '0', unidadPresentacion: UnidadDosis.g),
        isA<DosisInvalida>(),
      );
      expect(
        calculo('500', '10', '0.0', unidadPresentacion: UnidadDosis.mcg),
        isA<DosisInvalida>(),
      );
    });

    test('campos vacíos son inválidos', () {
      expect(calculo('', '10', '1000'), isA<DosisInvalida>());
      expect(calculo('500', '', '1000'), isA<DosisInvalida>());
      expect(calculo('500', '10', ''), isA<DosisInvalida>());
      expect(calculo('', '', ''), isA<DosisInvalida>());
    });

    test('texto no numérico es inválido', () {
      expect(calculo('abc', '10', '1000'), isA<DosisInvalida>());
      // El formatter del campo permite escribir solo el punto decimal.
      expect(calculo('.', '10', '1000'), isA<DosisInvalida>());
      expect(calculo('500', '10', '.'), isA<DosisInvalida>());
    });

    test('dosis en cero es válida y da cero ml', () {
      // (0 * 10) / 1000 = 0 ml
      expect(
        mlDe(
          '0',
          '10',
          '1000',
          unidadDosis: UnidadDosis.mg,
          unidadPresentacion: UnidadDosis.mg,
        ),
        0,
      );
    });

    test('un resultado de 10000 ml o más se rechaza', () {
      // 1 g = 1000 mg. (1000 * 10) / 1 = 10000 ml -> justo en el límite
      expect(
        calculo(
          '1',
          '10',
          '1',
          unidadDosis: UnidadDosis.g,
          unidadPresentacion: UnidadDosis.mg,
        ),
        isA<DosisDemasiadoGrande>(),
      );
      // 1 g = 1000 mg; 1 mcg = 0.001 mg. (1000 * 1) / 0.001 = 1000000 ml
      expect(
        calculo(
          '1',
          '1',
          '1',
          unidadDosis: UnidadDosis.g,
          unidadPresentacion: UnidadDosis.mcg,
        ),
        isA<DosisDemasiadoGrande>(),
      );
    });

    test('justo por debajo del límite sigue siendo válido', () {
      // (9999 * 1) / 1 = 9999 ml
      expect(
        mlDe(
          '9999',
          '1',
          '1',
          unidadDosis: UnidadDosis.mg,
          unidadPresentacion: UnidadDosis.mg,
        ),
        closeTo(9999.0, 1e-9),
      );
      // El límite mira la parte entera: 9999.5 ml todavía pasa.
      expect(
        mlDe(
          '9999.5',
          '1',
          '1',
          unidadDosis: UnidadDosis.mg,
          unidadPresentacion: UnidadDosis.mg,
        ),
        closeTo(9999.5, 1e-9),
      );
    });

    test('el diluyente en cero da cero ml, no un error', () {
      // (500 * 0) / 1000 = 0 ml
      expect(
        mlDe(
          '500',
          '0',
          '1000',
          unidadDosis: UnidadDosis.mg,
          unidadPresentacion: UnidadDosis.mg,
        ),
        0,
      );
    });
  });

  // ================================================================
  // FORMATO DEL RESULTADO DEL CONVERSOR
  // ================================================================
  group('formatearCantidad', () {
    test('números grandes sin notación científica ni ceros basura', () {
      // 1 g -> mcg = 1000000
      expect(
        formatearCantidad(
          convertirDosis(
            valor: 1,
            origen: UnidadDosis.g,
            destino: UnidadDosis.mcg,
          ),
        ),
        '1000000',
      );
      expect(formatearCantidad(2500), '2500');
    });

    test('números muy chicos sin notación científica', () {
      // 1 mcg -> g = 0.000001
      expect(
        formatearCantidad(
          convertirDosis(
            valor: 1,
            origen: UnidadDosis.mcg,
            destino: UnidadDosis.g,
          ),
        ),
        '0.000001',
      );
      // 0.5 mcg -> g = 0.0000005
      expect(
        formatearCantidad(
          convertirDosis(
            valor: 0.5,
            origen: UnidadDosis.mcg,
            destino: UnidadDosis.g,
          ),
        ),
        '0.0000005',
      );
    });

    test('esconde el ruido de punto flotante', () {
      // 0.1 mg -> mcg da 100.00000000000001 en coma flotante
      expect(
        formatearCantidad(
          convertirDosis(
            valor: 0.1,
            origen: UnidadDosis.mg,
            destino: UnidadDosis.mcg,
          ),
        ),
        '100',
      );
      // 3 mcg -> g da 3.0000000000000004e-6
      expect(
        formatearCantidad(
          convertirDosis(
            valor: 3,
            origen: UnidadDosis.mcg,
            destino: UnidadDosis.g,
          ),
        ),
        '0.000003',
      );
    });

    test('conserva los decimales significativos', () {
      expect(formatearCantidad(1.5), '1.5');
      expect(formatearCantidad(0.25), '0.25');
      expect(formatearCantidad(123.456), '123.456');
    });

    test('el cero se muestra como 0', () {
      expect(formatearCantidad(0), '0');
    });

    test('nunca aparece la letra e en el rango de trabajo', () {
      final valores = <double>[
        convertirDosis(
          valor: 9999999,
          origen: UnidadDosis.g,
          destino: UnidadDosis.mcg,
        ),
        convertirDosis(
          valor: 0.00001,
          origen: UnidadDosis.mcg,
          destino: UnidadDosis.g,
        ),
      ];
      for (final valor in valores) {
        final texto = formatearCantidad(valor);
        expect(texto.contains('e'), isFalse, reason: texto);
        expect(texto.contains('E'), isFalse, reason: texto);
      }
    });
  });
}
