// Valida las tablas de signos vitales pediátricos ANTES de compilar un APK.
//
// Las tablas las transcribió una persona a partir de una fotografía, así que
// el riesgo real no es un error de código sino un dígito mal copiado. La
// prueba de continuidad recorre los datos y falla si aparece un hueco o un
// traslape entre categorías: es la que atrapa ese error sin que nadie tenga
// que cotejar renglón por renglón.
//
// Todo lo que se prueba aquí son funciones puras: sin widgets y sin base de
// datos.
//
// Correr con:  flutter test test/signos_vitales_pediatricos_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:nursia_app/utils/signos_vitales_pediatricos.dart';

void main() {
  group('continuidad de las tablas', () {
    test('frecuencia cardiaca y respiratoria: sin huecos ni traslapes', () {
      // Se recorren los datos, no una lista de casos escritos a mano: así la
      // prueba sigue sirviendo cuando la tabla crezca o se corrija.
      for (final entrada in {
        'cardiaca': tablaFrecuenciaCardiaca,
        'respiratoria': tablaFrecuenciaRespiratoria,
      }.entries) {
        for (final r in entrada.value) {
          final donde = '${entrada.key}, meses ${r.mesesMin}-${r.mesesMax}';

          expect(
            r.bajoMax < r.normalMax,
            isTrue,
            reason: 'En $donde lo normal no empieza después de lo bajo.',
          );
          expect(
            r.normalMax < r.leveMax,
            isTrue,
            reason: 'En $donde la leve se encima con lo normal.',
          );
          expect(
            r.leveMax < r.moderadaMax,
            isTrue,
            reason: 'En $donde la moderada se encima con la leve.',
          );

          // Cada valor del renglón cae en una sola categoría, y al pasar de
          // una a la siguiente el nivel sube sin saltarse ninguna.
          final niveles = <NivelSigno>[];
          for (var v = 1; v <= r.moderadaMax + 5; v++) {
            final nivel = entrada.key == 'cardiaca'
                ? interpretarFrecuenciaCardiaca(v, r.mesesMin).nivel
                : interpretarFrecuenciaRespiratoria(v, r.mesesMin).nivel;
            if (niveles.isEmpty || niveles.last != nivel) niveles.add(nivel);
          }
          expect(
            niveles,
            const [
              NivelSigno.bajo,
              NivelSigno.normal,
              NivelSigno.leve,
              NivelSigno.moderada,
              NivelSigno.grave,
            ],
            reason: 'En $donde las categorías no van en orden y sin huecos.',
          );
        }
      }
    });

    test('presión arterial: la tabla es coherente renglón por renglón', () {
      for (final r in tablaPresionArterial) {
        final donde = 'meses ${r.mesesMin}-${r.mesesMax}';
        expect(
          r.hipotensionSistolicaMax < r.sistolicaNormalMin,
          isTrue,
          reason: 'En $donde la hipotensión se encima con lo normal.',
        );
        expect(
          r.sistolicaNormalMax + 1,
          r.hipertensionSistolica,
          reason:
              'En $donde queda un hueco entre lo normal y la hipertensión '
              'sistólica.',
        );
        expect(
          r.diastolicaNormalMin < r.diastolicaNormalMax,
          isTrue,
          reason: 'En $donde el rango diastólico normal está invertido.',
        );
        expect(
          r.diastolicaNormalMax + 1,
          r.hipertensionDiastolica,
          reason:
              'En $donde queda un hueco entre lo normal y la hipertensión '
              'diastólica.',
        );
      }
    });
  });

  group('cobertura de edad', () {
    test('0 a 227 meses cae en exactamente un renglón de FC y de FR', () {
      for (var meses = 0; meses <= 227; meses++) {
        for (final tabla in [
          tablaFrecuenciaCardiaca,
          tablaFrecuenciaRespiratoria,
        ]) {
          final coinciden = tabla.where((r) => r.cubre(meses)).length;
          expect(
            coinciden,
            1,
            reason:
                'El mes $meses cae en $coinciden '
                'renglones, debería caer en exactamente uno.',
          );
        }
      }
    });

    test('0 a 215 meses cae en exactamente un renglón de presión', () {
      for (var meses = 0; meses <= 215; meses++) {
        final coinciden = tablaPresionArterial
            .where((r) => r.cubre(meses))
            .length;
        expect(
          coinciden,
          1,
          reason:
              'El mes $meses cae en $coinciden '
              'renglones de presión.',
        );
      }
    });
  });

  group('fronteras de cada categoría', () {
    test('menor de 3 meses, frecuencia cardiaca', () {
      expect(interpretarFrecuenciaCardiaca(80, 0).etiqueta, 'Bradicardia');
      expect(interpretarFrecuenciaCardiaca(81, 0).etiqueta, 'Normal');
      expect(interpretarFrecuenciaCardiaca(164, 0).etiqueta, 'Normal');
      expect(
        interpretarFrecuenciaCardiaca(165, 0).etiqueta,
        'Taquicardia leve',
      );
      expect(
        interpretarFrecuenciaCardiaca(171, 0).etiqueta,
        'Taquicardia leve',
      );
      expect(
        interpretarFrecuenciaCardiaca(172, 0).etiqueta,
        'Taquicardia moderada',
      );
      expect(
        interpretarFrecuenciaCardiaca(186, 0).etiqueta,
        'Taquicardia moderada',
      );
      expect(
        interpretarFrecuenciaCardiaca(187, 0).etiqueta,
        'Taquicardia grave',
      );
    });

    test('2 años, frecuencia cardiaca', () {
      expect(interpretarFrecuenciaCardiaca(60, 24).etiqueta, 'Bradicardia');
      expect(interpretarFrecuenciaCardiaca(61, 24).etiqueta, 'Normal');
      expect(interpretarFrecuenciaCardiaca(142, 24).etiqueta, 'Normal');
      expect(
        interpretarFrecuenciaCardiaca(143, 24).etiqueta,
        'Taquicardia leve',
      );
      expect(
        interpretarFrecuenciaCardiaca(150, 24).etiqueta,
        'Taquicardia leve',
      );
      expect(
        interpretarFrecuenciaCardiaca(151, 24).etiqueta,
        'Taquicardia moderada',
      );
      expect(
        interpretarFrecuenciaCardiaca(167, 24).etiqueta,
        'Taquicardia moderada',
      );
      expect(
        interpretarFrecuenciaCardiaca(168, 24).etiqueta,
        'Taquicardia grave',
      );
    });

    test('15 a 18 años, frecuencia cardiaca', () {
      expect(interpretarFrecuenciaCardiaca(50, 180).etiqueta, 'Bradicardia');
      expect(interpretarFrecuenciaCardiaca(51, 180).etiqueta, 'Normal');
      expect(interpretarFrecuenciaCardiaca(107, 180).etiqueta, 'Normal');
      expect(
        interpretarFrecuenciaCardiaca(108, 180).etiqueta,
        'Taquicardia leve',
      );
      expect(
        interpretarFrecuenciaCardiaca(115, 180).etiqueta,
        'Taquicardia leve',
      );
      expect(
        interpretarFrecuenciaCardiaca(116, 180).etiqueta,
        'Taquicardia moderada',
      );
      expect(
        interpretarFrecuenciaCardiaca(132, 180).etiqueta,
        'Taquicardia moderada',
      );
      expect(
        interpretarFrecuenciaCardiaca(133, 180).etiqueta,
        'Taquicardia grave',
      );
    });

    test('los dos valores corregidos de frecuencia respiratoria', () {
      // Corrección 1: en 15 a 18 años la moderada va de 27 a 31, no "37-32".
      expect(
        interpretarFrecuenciaRespiratoria(26, 180).etiqueta,
        'Taquipnea leve',
      );
      expect(
        interpretarFrecuenciaRespiratoria(27, 180).etiqueta,
        'Taquipnea moderada',
      );
      expect(
        interpretarFrecuenciaRespiratoria(31, 180).etiqueta,
        'Taquipnea moderada',
      );
      expect(
        interpretarFrecuenciaRespiratoria(32, 180).etiqueta,
        'Taquipnea grave',
      );

      // Corrección 2: en menor de 3 meses el 30 es bradipnea y lo normal
      // empieza en 31. La hoja ponía el 30 en las dos categorías.
      expect(interpretarFrecuenciaRespiratoria(30, 0).etiqueta, 'Bradipnea');
      expect(interpretarFrecuenciaRespiratoria(31, 0).etiqueta, 'Normal');
    });

    test('6 a 7 años, frecuencia respiratoria', () {
      expect(interpretarFrecuenciaRespiratoria(15, 72).etiqueta, 'Bradipnea');
      expect(interpretarFrecuenciaRespiratoria(16, 72).etiqueta, 'Normal');
      expect(interpretarFrecuenciaRespiratoria(31, 72).etiqueta, 'Normal');
      expect(
        interpretarFrecuenciaRespiratoria(32, 72).etiqueta,
        'Taquipnea leve',
      );
      expect(
        interpretarFrecuenciaRespiratoria(35, 72).etiqueta,
        'Taquipnea leve',
      );
      expect(
        interpretarFrecuenciaRespiratoria(36, 72).etiqueta,
        'Taquipnea moderada',
      );
      expect(
        interpretarFrecuenciaRespiratoria(46, 72).etiqueta,
        'Taquipnea moderada',
      );
      expect(
        interpretarFrecuenciaRespiratoria(47, 72).etiqueta,
        'Taquipnea grave',
      );
    });
  });

  group('edad fuera de rango y edad faltante', () {
    test(
      '228 meses en frecuencia cardiaca no devuelve el renglón más alto',
      () {
        final r = interpretarFrecuenciaCardiaca(90, 228);
        expect(r.nivel, NivelSigno.noValorable);
        expect(r.etiqueta, contains('fuera del rango'));
        // El renglón de 15 a 18 años habría dicho "Normal" para 90 lpm.
        expect(r.etiqueta, isNot('Normal'));
      },
    );

    test('216 meses en presión arterial queda fuera de rango', () {
      // FC y FR llegan a 227 meses; la presión solo a 215. Un paciente de 18
      // años tiene FC y FR pero no tiene renglón de presión.
      expect(interpretarFrecuenciaCardiaca(90, 216).nivel, NivelSigno.normal);
      final r = interpretarPresionArterial(
        sistolica: 110,
        diastolica: 70,
        meses: 216,
      );
      expect(r.nivel, NivelSigno.noValorable);
      expect(r.etiqueta, contains('fuera del rango'));
    });

    test('sin edad, los tres signos que dependen de ella lo dicen', () {
      for (final r in [
        interpretarFrecuenciaCardiaca(100, null),
        interpretarFrecuenciaRespiratoria(30, null),
        interpretarPresionArterial(sistolica: 100, meses: null),
      ]) {
        expect(r.nivel, NivelSigno.noValorable);
        expect(r.etiqueta, contains('requiere la edad'));
      }
    });

    test('saturación y temperatura no necesitan edad', () {
      expect(interpretarSaturacion(97).etiqueta, 'Normal');
      expect(interpretarTemperatura(36.8).etiqueta, 'Normal');
    });
  });

  group('presión arterial', () {
    test('la zona muerta sistólica no se redondea a ningún lado', () {
      // Recién nacido: hipotensión ≤65, lo normal empieza en 75. El 70 cae en
      // el hueco.
      final r = interpretarPresionArterial(sistolica: 70, meses: 0);
      expect(r.nivel, NivelSigno.bajo);
      expect(r.etiqueta, 'Sistólica por debajo de lo normal');
      expect(r.etiqueta, isNot(contains('Hipotensión')));
      expect(r.etiqueta, isNot(contains('normal,')));

      // Las dos orillas del hueco sí están clasificadas.
      expect(
        interpretarPresionArterial(sistolica: 65, meses: 0).etiqueta,
        'Hipotensión sistólica',
      );
      expect(
        interpretarPresionArterial(sistolica: 75, meses: 0).etiqueta,
        'Sistólica normal',
      );
    });

    test('la diastólica baja no se llama hipotensión', () {
      final r = interpretarPresionArterial(diastolica: 20, meses: 0);
      expect(r.etiqueta, 'Diastólica por debajo de lo normal');
      expect(r.etiqueta.toLowerCase(), isNot(contains('hipotensión')));
    });

    test('la hipertensión son dos umbrales independientes', () {
      // Recién nacido, par 100/70.
      expect(
        interpretarPresionArterial(
          sistolica: 100,
          diastolica: 60,
          meses: 0,
        ).etiqueta,
        'Hipertensión sistólica, diastólica normal',
      );
      expect(
        interpretarPresionArterial(
          sistolica: 90,
          diastolica: 70,
          meses: 0,
        ).etiqueta,
        'Sistólica normal, hipertensión diastólica',
      );
      expect(
        interpretarPresionArterial(
          sistolica: 100,
          diastolica: 70,
          meses: 0,
        ).etiqueta,
        'Hipertensión sistólica, hipertensión diastólica',
      );
    });

    test('se interpreta un solo componente si es el único capturado', () {
      expect(
        interpretarPresionArterial(sistolica: 90, meses: 0).etiqueta,
        'Sistólica normal',
      );
      expect(
        interpretarPresionArterial(diastolica: 50, meses: 0).etiqueta,
        'Diastólica normal',
      );
    });
  });

  group('conversión de edad', () {
    test('1 año son 12 meses y cae donde debe', () {
      expect(aMeses(1, UnidadEdad.anios), 12);
      // 12 meses es el renglón "1 año a 1 año 5 meses" de FC y FR.
      expect(
        tablaFrecuenciaCardiaca.firstWhere((r) => r.cubre(12)).mesesMin,
        12,
      );
      expect(
        tablaFrecuenciaRespiratoria.firstWhere((r) => r.cubre(12)).mesesMin,
        12,
      );
      // En presión, 12 meses cae en el renglón de "1 año" (12 a 23).
      expect(tablaPresionArterial.firstWhere((r) => r.cubre(12)).mesesMax, 23);
    });

    test('18 meses caen en "1 año 6 meses a 1 año 11 meses"', () {
      final fc = tablaFrecuenciaCardiaca.firstWhere((r) => r.cubre(18));
      expect(fc.mesesMin, 18);
      expect(fc.mesesMax, 23);
      expect(aMeses(18, UnidadEdad.meses), 18);
    });
  });

  group('saturación y temperatura', () {
    test('fronteras de saturación', () {
      expect(interpretarSaturacion(100).etiqueta, 'Normal');
      expect(interpretarSaturacion(95).etiqueta, 'Normal');
      expect(interpretarSaturacion(94).etiqueta, 'Desaturación leve');
      expect(interpretarSaturacion(90).etiqueta, 'Desaturación leve');
      expect(interpretarSaturacion(89).etiqueta, 'Desaturación moderada');
      expect(interpretarSaturacion(85).etiqueta, 'Desaturación moderada');
      expect(interpretarSaturacion(84).etiqueta, 'Desaturación severa');
    });

    test('fronteras de temperatura, axilar y sin depender de la edad', () {
      expect(
        interpretarTemperatura(35.9).etiqueta,
        'Por debajo del rango normal',
      );
      expect(interpretarTemperatura(36.0).etiqueta, 'Normal');
      expect(interpretarTemperatura(37.5).etiqueta, 'Normal');
      expect(interpretarTemperatura(37.6).etiqueta, 'Febrícula');
      expect(interpretarTemperatura(37.9).etiqueta, 'Febrícula');
      expect(interpretarTemperatura(38.0).etiqueta, 'Fiebre');
      expect(interpretarTemperatura(40.0).etiqueta, 'Fiebre');
    });

    test('un valor bajo de temperatura no se llama hipotermia', () {
      // No se encontró un corte de hipotermia axilar pediátrica en fuente
      // citable, así que el resultado no le pone ese nombre.
      expect(
        interpretarTemperatura(30.0).etiqueta.toLowerCase(),
        isNot(contains('hipotermia')),
      );
    });
  });
}
