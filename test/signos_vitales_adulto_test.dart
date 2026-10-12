// Valida los cortes de signos vitales del adulto: NOM-030-SSA2-2009 para la
// presión arterial y NEWS2 para lo demás. Se prueban las fronteras exactas,
// que es donde un `<` en vez de `<=` cambia el resultado.
//
// Correr con:  flutter test test/signos_vitales_adulto_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:nursia_app/utils/signos_vitales_adulto.dart';
import 'package:nursia_app/utils/signos_vitales_pediatricos.dart'
    show NivelSigno;

void main() {
  // Normal 50 a 100 (ACC/AHA/HRS 2018); la gravedad fuera de ahí, NEWS2.
  test('frecuencia cardiaca', () {
    final casos = {
      40: NivelSigno.grave,
      41: NivelSigno.leve,
      49: NivelSigno.leve,
      50: NivelSigno.normal,
      100: NivelSigno.normal,
      101: NivelSigno.leve,
      110: NivelSigno.leve,
      111: NivelSigno.moderada,
      130: NivelSigno.moderada,
      131: NivelSigno.grave,
    };
    casos.forEach((lpm, nivel) {
      expect(interpretarFrecuenciaCardiacaAdulto(lpm).nivel, nivel,
          reason: '$lpm lpm');
    });
  });

  test('frecuencia respiratoria (NEWS2)', () {
    final casos = {
      8: NivelSigno.grave,
      9: NivelSigno.leve,
      11: NivelSigno.leve,
      12: NivelSigno.normal,
      20: NivelSigno.normal,
      21: NivelSigno.moderada,
      24: NivelSigno.moderada,
      25: NivelSigno.grave,
    };
    casos.forEach((rpm, nivel) {
      expect(interpretarFrecuenciaRespiratoriaAdulto(rpm).nivel, nivel,
          reason: '$rpm rpm');
    });
  });

  test('temperatura (NEWS2)', () {
    final casos = {
      35.0: 'Hipotermia',
      35.1: 'Por debajo del rango normal',
      36.0: 'Por debajo del rango normal',
      36.1: 'Normal',
      38.0: 'Normal',
      38.1: 'Fiebre',
      39.0: 'Fiebre',
      39.1: 'Fiebre elevada',
    };
    casos.forEach((grados, etiqueta) {
      expect(interpretarTemperaturaAdulto(grados).etiqueta, etiqueta,
          reason: '$grados °C');
    });
  });

  group('saturación (NEWS2)', () {
    test('escala 1', () {
      final casos = {
        96: NivelSigno.normal,
        95: NivelSigno.leve,
        94: NivelSigno.leve,
        93: NivelSigno.moderada,
        92: NivelSigno.moderada,
        91: NivelSigno.grave,
      };
      casos.forEach((p, nivel) {
        expect(interpretarSaturacionAdulto(p).nivel, nivel, reason: '$p%');
      });
    });

    test('escala 1 ignora conOxigeno', () {
      expect(interpretarSaturacionAdulto(99, conOxigeno: true).nivel,
          NivelSigno.normal);
    });

    test('escala 2 (EPOC), lado bajo y meta', () {
      final casos = {
        83: NivelSigno.grave,
        84: NivelSigno.moderada,
        85: NivelSigno.moderada,
        86: NivelSigno.leve,
        87: NivelSigno.leve,
        88: NivelSigno.normal,
        92: NivelSigno.normal,
      };
      casos.forEach((p, nivel) {
        expect(interpretarSaturacionAdulto(p, epoc: true).nivel, nivel,
            reason: '$p%');
      });
    });

    test('escala 2 (EPOC), por arriba de la meta depende del oxígeno', () {
      expect(interpretarSaturacionAdulto(99, epoc: true).nivel,
          NivelSigno.normal);
      final conO2 = {
        93: NivelSigno.leve,
        94: NivelSigno.leve,
        95: NivelSigno.moderada,
        96: NivelSigno.moderada,
        97: NivelSigno.grave,
      };
      conO2.forEach((p, nivel) {
        expect(
          interpretarSaturacionAdulto(p, epoc: true, conOxigeno: true).nivel,
          nivel,
          reason: '$p% con O2',
        );
      });
    });
  });

  group('presión arterial (NOM-030)', () {
    test('límites crecientes y del mismo largo que las categorías', () {
      for (final l in [limitesSistolica, limitesDiastolica]) {
        expect(l.length, CategoriaPresion.values.length);
        for (var i = 1; i < l.length; i++) {
          expect(l[i] > l[i - 1], isTrue);
        }
      }
    });

    test('fronteras de la sistólica', () {
      final casos = {
        119: CategoriaPresion.optima,
        120: CategoriaPresion.normal,
        129: CategoriaPresion.normal,
        130: CategoriaPresion.fronteriza,
        139: CategoriaPresion.fronteriza,
        140: CategoriaPresion.hipertension1,
        159: CategoriaPresion.hipertension1,
        160: CategoriaPresion.hipertension2,
        179: CategoriaPresion.hipertension2,
        180: CategoriaPresion.hipertension3,
      };
      casos.forEach((v, c) => expect(categoriaSistolica(v), c, reason: '$v'));
    });

    test('fronteras de la diastólica', () {
      final casos = {
        79: CategoriaPresion.optima,
        80: CategoriaPresion.normal,
        84: CategoriaPresion.normal,
        85: CategoriaPresion.fronteriza,
        89: CategoriaPresion.fronteriza,
        90: CategoriaPresion.hipertension1,
        99: CategoriaPresion.hipertension1,
        100: CategoriaPresion.hipertension2,
        109: CategoriaPresion.hipertension2,
        110: CategoriaPresion.hipertension3,
      };
      casos.forEach((v, c) => expect(categoriaDiastolica(v), c, reason: '$v'));
    });

    test('manda el componente más alto', () {
      expect(
        interpretarPresionArterialAdulto(sistolica: 125, diastolica: 102)!
            .etiqueta,
        'Hipertensión etapa 2',
      );
    });

    test('hipertensión sistólica aislada', () {
      final r = interpretarPresionArterialAdulto(sistolica: 165, diastolica: 85)!;
      expect(r.etiqueta, 'Hipertensión sistólica aislada');
      expect(r.nivel, NivelSigno.grave);
      // Sin diastólica no se puede afirmar que sea aislada.
      expect(interpretarPresionArterialAdulto(sistolica: 165)!.etiqueta,
          'Hipertensión etapa 2');
    });

    test('hipotensión manda sobre todo', () {
      expect(interpretarPresionArterialAdulto(sistolica: 90)!.etiqueta,
          'Hipotensión');
      expect(
        interpretarPresionArterialAdulto(sistolica: 85, diastolica: 95)!
            .etiqueta,
        'Hipotensión',
      );
      expect(interpretarPresionArterialAdulto(sistolica: 91)!.etiqueta,
          'Presión óptima');
    });

    test('sin datos devuelve null', () {
      expect(interpretarPresionArterialAdulto(), isNull);
    });
  });
}
