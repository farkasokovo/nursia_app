// test/calculadora_goteo_test.dart
//
// Pruebas de la lógica del goteo IV (lib/utils/calculo_goteo.dart).
//
// Es una calculadora clínica: confundir horas con minutos es un error de factor
// 60 y daría un ritmo de infusión equivocado. Todos los resultados esperados de
// este archivo están calculados a mano y anotados junto a cada caso; ninguno se
// obtuvo corriendo el código.
//
// Fórmula usada en todas las cuentas de abajo:
//   gotas/min = (volumen en ml × factor de goteo) ÷ tiempo en minutos
//   Factores: micro 60 gotas/ml · normo 20 gotas/ml · macro 15 gotas/ml

import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/utils/calculo_goteo.dart';

/// Azúcar para leer los casos: devuelve las gotas/min de un cálculo válido.
int gotasDe(
  String volumen,
  String tiempo, {
  required TipoEquipo equipo,
  required UnidadTiempo unidadTiempo,
}) {
  final resultado = calcularGoteo(
    volumenTexto: volumen,
    tiempoTexto: tiempo,
    equipo: equipo,
    unidadTiempo: unidadTiempo,
  );
  expect(
    resultado,
    isA<GoteoCalculado>(),
    reason:
        'Se esperaba un cálculo válido para $volumen ml en $tiempo '
        '${unidadTiempo.label}',
  );
  return (resultado as GoteoCalculado).gotasPorMinuto;
}

ResultadoGoteo calculo(
  String volumen,
  String tiempo, {
  TipoEquipo equipo = TipoEquipo.normo,
  UnidadTiempo unidadTiempo = UnidadTiempo.horas,
}) {
  return calcularGoteo(
    volumenTexto: volumen,
    tiempoTexto: tiempo,
    equipo: equipo,
    unidadTiempo: unidadTiempo,
  );
}

void main() {
  // ================================================================
  // FACTORES Y CONVERSIÓN DE TIEMPO
  // ================================================================
  group('factores de goteo del equipo', () {
    test('cada equipo conserva su factor', () {
      expect(TipoEquipo.micro.factorGoteo, 60);
      expect(TipoEquipo.normo.factorGoteo, 20);
      expect(TipoEquipo.macro.factorGoteo, 15);
    });
  });

  group('UnidadTiempo.aMinutos', () {
    test('las horas se multiplican por 60', () {
      expect(UnidadTiempo.horas.aMinutos(1), 60);
      expect(UnidadTiempo.horas.aMinutos(8), 480);
      expect(UnidadTiempo.horas.aMinutos(0.5), 30);
    });

    test('los minutos no se convierten', () {
      expect(UnidadTiempo.minutos.aMinutos(30), 30);
      expect(UnidadTiempo.minutos.aMinutos(1), 1);
    });
  });

  // ================================================================
  // CÁLCULO EN HORAS (comportamiento previo, no debe cambiar)
  // ================================================================
  group('calcularGoteo en horas', () {
    test('1000 ml en 8 horas con normogotero', () {
      // (1000 × 20) ÷ (8 × 60) = 20000 ÷ 480 = 41.66... -> 42
      expect(
        gotasDe(
          '1000',
          '8',
          equipo: TipoEquipo.normo,
          unidadTiempo: UnidadTiempo.horas,
        ),
        42,
      );
    });

    test('500 ml en 4 horas con macrogotero', () {
      // (500 × 15) ÷ 240 = 7500 ÷ 240 = 31.25 -> 31
      expect(
        gotasDe(
          '500',
          '4',
          equipo: TipoEquipo.macro,
          unidadTiempo: UnidadTiempo.horas,
        ),
        31,
      );
    });

    test('1000 ml en 24 horas con normogotero', () {
      // (1000 × 20) ÷ 1440 = 20000 ÷ 1440 = 13.88... -> 14
      expect(
        gotasDe(
          '1000',
          '24',
          equipo: TipoEquipo.normo,
          unidadTiempo: UnidadTiempo.horas,
        ),
        14,
      );
    });

    test('60 ml en 1 hora con microgotero', () {
      // (60 × 60) ÷ 60 = 60
      expect(
        gotasDe(
          '60',
          '1',
          equipo: TipoEquipo.micro,
          unidadTiempo: UnidadTiempo.horas,
        ),
        60,
      );
    });
  });

  // ================================================================
  // CÁLCULO EN MINUTOS (lo nuevo)
  // ================================================================
  group('calcularGoteo en minutos', () {
    test('100 ml en 30 minutos con macrogotero', () {
      // (100 × 15) ÷ 30 = 1500 ÷ 30 = 50
      expect(
        gotasDe(
          '100',
          '30',
          equipo: TipoEquipo.macro,
          unidadTiempo: UnidadTiempo.minutos,
        ),
        50,
      );
    });

    test('100 ml en 20 minutos con normogotero', () {
      // (100 × 20) ÷ 20 = 2000 ÷ 20 = 100
      expect(
        gotasDe(
          '100',
          '20',
          equipo: TipoEquipo.normo,
          unidadTiempo: UnidadTiempo.minutos,
        ),
        100,
      );
    });

    test('50 ml en 30 minutos con microgotero', () {
      // (50 × 60) ÷ 30 = 3000 ÷ 30 = 100
      expect(
        gotasDe(
          '50',
          '30',
          equipo: TipoEquipo.micro,
          unidadTiempo: UnidadTiempo.minutos,
        ),
        100,
      );
    });

    test('250 ml en 45 minutos con macrogotero', () {
      // (250 × 15) ÷ 45 = 3750 ÷ 45 = 83.33... -> 83
      expect(
        gotasDe(
          '250',
          '45',
          equipo: TipoEquipo.macro,
          unidadTiempo: UnidadTiempo.minutos,
        ),
        83,
      );
    });
  });

  // ================================================================
  // EQUIVALENCIA ENTRE LAS DOS UNIDADES
  // ================================================================
  group('horas y minutos describen el mismo tiempo', () {
    test('100 ml en 30 minutos = 100 ml en 0.5 horas (macrogotero)', () {
      // Caso de validación: (100 × 15) ÷ 30 = 50 por los dos caminos.
      final enMinutos = gotasDe(
        '100',
        '30',
        equipo: TipoEquipo.macro,
        unidadTiempo: UnidadTiempo.minutos,
      );
      final enHoras = gotasDe(
        '100',
        '0.5',
        equipo: TipoEquipo.macro,
        unidadTiempo: UnidadTiempo.horas,
      );
      expect(enMinutos, 50);
      expect(enHoras, 50);
      expect(enMinutos, enHoras);
    });

    test('N horas da lo mismo que N×60 minutos, en los tres equipos', () {
      // Barrido: si la conversión de unidad se equivocara por un factor 60,
      // alguna de estas parejas dejaría de coincidir.
      const casos = <(String volumen, int horas)>[
        ('1000', 8),
        ('500', 4),
        ('1000', 24),
        ('250', 2),
        ('100', 1),
      ];
      for (final equipo in TipoEquipo.values) {
        for (final (volumen, horas) in casos) {
          final enHoras = gotasDe(
            volumen,
            '$horas',
            equipo: equipo,
            unidadTiempo: UnidadTiempo.horas,
          );
          final enMinutos = gotasDe(
            volumen,
            '${horas * 60}',
            equipo: equipo,
            unidadTiempo: UnidadTiempo.minutos,
          );
          expect(
            enMinutos,
            enHoras,
            reason:
                '$volumen ml en $horas h vs ${horas * 60} min '
                'con ${equipo.nombreLargo}',
          );
        }
      }
    });

    test('coincide con la fórmula clásica volumen ÷ (horas × constante)', () {
      // Constante = 60 ÷ factor: micro 1, normo 3, macro 4.
      const constantes = {
        TipoEquipo.micro: 1,
        TipoEquipo.normo: 3,
        TipoEquipo.macro: 4,
      };
      for (final equipo in TipoEquipo.values) {
        for (final volumen in [1000, 500, 250, 100]) {
          for (final horas in [1, 2, 4, 8, 12, 24]) {
            final esperado = (volumen / (horas * constantes[equipo]!)).round();
            if (esperado <= 0 || esperado >= 1000) continue;
            expect(
              gotasDe(
                '$volumen',
                '$horas',
                equipo: equipo,
                unidadTiempo: UnidadTiempo.horas,
              ),
              esperado,
              reason: '$volumen ml en $horas h con ${equipo.nombreLargo}',
            );
          }
        }
      }
    });
  });

  // ================================================================
  // CASOS LÍMITE
  // ================================================================
  group('casos límite', () {
    test('campos vacíos o no numéricos son inválidos', () {
      expect(calculo('', '8'), isA<GoteoInvalido>());
      expect(calculo('1000', ''), isA<GoteoInvalido>());
      expect(calculo('', ''), isA<GoteoInvalido>());
      expect(calculo('abc', '8'), isA<GoteoInvalido>());
    });

    test('volumen o tiempo en cero son inválidos (no divide entre cero)', () {
      expect(calculo('0', '8'), isA<GoteoInvalido>());
      expect(calculo('1000', '0'), isA<GoteoInvalido>());
      expect(
        calculo('1000', '0', unidadTiempo: UnidadTiempo.minutos),
        isA<GoteoInvalido>(),
      );
    });

    test('un ritmo que redondea a 0 gotas/min se rechaza', () {
      // (1 × 60) ÷ (999 × 60) = 0.001 -> 0
      expect(
        calculo('1', '999', equipo: TipoEquipo.micro),
        isA<GoteoDemasiadoLento>(),
      );
      // (1 × 15) ÷ 999 = 0.015 -> 0
      expect(
        calculo(
          '1',
          '999',
          equipo: TipoEquipo.macro,
          unidadTiempo: UnidadTiempo.minutos,
        ),
        isA<GoteoDemasiadoLento>(),
      );
    });

    test('1000 gotas/min o más se rechaza', () {
      // (1000 × 60) ÷ 60 = 1000
      expect(
        calculo(
          '1000',
          '60',
          equipo: TipoEquipo.micro,
          unidadTiempo: UnidadTiempo.minutos,
        ),
        isA<GoteoDemasiadoRapido>(),
      );
      // (100 × 15) ÷ 1 = 1500
      expect(
        calculo(
          '100',
          '1',
          equipo: TipoEquipo.macro,
          unidadTiempo: UnidadTiempo.minutos,
        ),
        isA<GoteoDemasiadoRapido>(),
      );
    });

    test('999 gotas/min todavía es válido', () {
      // (999 × 60) ÷ 60 = 999
      expect(
        gotasDe(
          '999',
          '60',
          equipo: TipoEquipo.micro,
          unidadTiempo: UnidadTiempo.minutos,
        ),
        999,
      );
    });

    test('el resultado recuerda el equipo con el que se calculó', () {
      final resultado = calculo('1000', '8', equipo: TipoEquipo.macro);
      expect((resultado as GoteoCalculado).equipo, TipoEquipo.macro);
    });

    test('1 ml en 1 minuto con macrogotero da 15 gotas/min', () {
      // Volumen mínimo capturable: (1 × 15) ÷ 1 = 15
      expect(
        gotasDe(
          '1',
          '1',
          equipo: TipoEquipo.macro,
          unidadTiempo: UnidadTiempo.minutos,
        ),
        15,
      );
    });
  });
}
