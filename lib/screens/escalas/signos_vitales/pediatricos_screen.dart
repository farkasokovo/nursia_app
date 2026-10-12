// lib/screens/escalas/signos_vitales/pediatricos_screen.dart
//
// Intérprete de signos vitales pediátricos: se captura la edad y uno o varios
// signos, y cada uno se interpreta por separado contra el renglón que le toca
// por edad.
//
// NO ES EL EVAT. Las tablas vienen de ese material pero aquí no se suma ningún
// puntaje. Las tablas y la lógica viven en utils/signos_vitales_pediatricos.
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../theme/theme_colors.dart';
import '../../../utils/signos_vitales_pediatricos.dart';
import '../../../widgets/expandable_category_screen.dart';
import '../../../widgets/numeric_input_field.dart';
import '../../../widgets/signos_vitales_comunes.dart';
import '../../../widgets/opcion_selector.dart';
import '../../../widgets/tabbed_content.dart';
import '../../../widgets/tabla_referencia.dart';

class SignosVitalesPediatricosScreen extends StatelessWidget {
  const SignosVitalesPediatricosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "signos_vitales_pediatricos",
      // Partido en dos renglones: la barra de ExpandableCategoryScreen no
      // recorta ni envuelve su Text, así que un título largo se desborda. Es
      // el mismo recurso que usa "Escalas Pediátricas\ny Neonatales".
      title: "Signos vitales\npediátricos",
      icon: PhosphorIconsFill.heartbeat,
      child: TabbedContent(
        tabs: [
          Tab(text: "Interpretación"),
          Tab(text: "Información"),
        ],
        tabViews: [_InterpretacionLayout(), _InformacionLayout()],
      ),
    );
  }
}

// ================== PESTAÑA DE INTERPRETACIÓN ==================
class _InterpretacionLayout extends StatefulWidget {
  const _InterpretacionLayout();

  @override
  State<_InterpretacionLayout> createState() => _InterpretacionLayoutState();
}

class _InterpretacionLayoutState extends State<_InterpretacionLayout>
    with AutomaticKeepAliveClientMixin {
  final _edadController = TextEditingController();
  final _fcController = TextEditingController();
  final _frController = TextEditingController();
  final _sistolicaController = TextEditingController();
  final _diastolicaController = TextEditingController();
  final _temperaturaController = TextEditingController();
  final _saturacionController = TextEditingController();

  final _edadFocus = FocusNode();
  final _fcFocus = FocusNode();
  final _frFocus = FocusNode();
  final _sistolicaFocus = FocusNode();
  final _diastolicaFocus = FocusNode();
  final _temperaturaFocus = FocusNode();
  final _saturacionFocus = FocusNode();

  UnidadEdad _unidad = UnidadEdad.anios;

  // Un resultado por signo, null hasta que se presiona "Interpretar". La
  // pastilla de cada uno se pinta debajo de su propio campo, así que el
  // resultado se guarda por separado y no como una lista de paneles.
  ResultadoSigno? _resultadoFc;
  ResultadoSigno? _resultadoFr;
  ResultadoSigno? _resultadoPresion;
  ResultadoSigno? _resultadoTemperatura;
  ResultadoSigno? _resultadoSaturacion;

  void _borrarResultados() {
    _resultadoFc = null;
    _resultadoFr = null;
    _resultadoPresion = null;
    _resultadoTemperatura = null;
    _resultadoSaturacion = null;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    for (final c in [
      _edadController,
      _fcController,
      _frController,
      _sistolicaController,
      _diastolicaController,
      _temperaturaController,
      _saturacionController,
    ]) {
      c.dispose();
    }
    for (final f in [
      _edadFocus,
      _fcFocus,
      _frFocus,
      _sistolicaFocus,
      _diastolicaFocus,
      _temperaturaFocus,
      _saturacionFocus,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 3)),
    );
  }

  /// Texto del campo sin espacios. Null cuando el campo está vacío o solo
  /// tiene espacios.
  String? _texto(TextEditingController c) {
    final limpio = c.text.trim();
    return limpio.isEmpty ? null : limpio;
  }

  void _interpretar() {
    // Quita el foco de todos los campos para que el teclado no tape los
    // paneles, igual que hace la calculadora de PAM.
    for (final f in [
      _edadFocus,
      _fcFocus,
      _frFocus,
      _sistolicaFocus,
      _diastolicaFocus,
      _temperaturaFocus,
      _saturacionFocus,
    ]) {
      f.unfocus();
    }

    // ── Edad ──
    // Se acepta vacía: la saturación y la temperatura no la necesitan.
    final edadTexto = _texto(_edadController);
    int? meses;
    if (edadTexto != null) {
      final valor = int.tryParse(edadTexto);
      final maximo = _unidad == UnidadEdad.anios
          ? edadMaximaAnios
          : edadMaximaMeses;
      if (valor == null || valor < 0 || valor > maximo) {
        setState(_borrarResultados);
        _avisar(
          'Revisa la edad: se acepta de 0 a $maximo '
          '${_unidad == UnidadEdad.anios ? "años" : "meses"}.',
        );
        return;
      }
      meses = aMeses(valor, _unidad);
    }

    // ── Signos vitales ──
    // Los campos fuera de rango no generan panel y se nombran todos juntos en
    // un solo aviso, para no encimar varios SnackBar.
    final fueraDeRango = <String>[];

    int? entero(TextEditingController c, String campo, int minimo, int maximo) {
      final texto = _texto(c);
      if (texto == null) return null;
      final valor = int.tryParse(texto);
      if (valor == null || valor < minimo || valor > maximo) {
        fueraDeRango.add(campo);
        return null;
      }
      return valor;
    }

    final fc = entero(
      _fcController,
      'frecuencia cardiaca',
      frecuenciaCardiacaMin,
      frecuenciaCardiacaMax,
    );
    final fr = entero(
      _frController,
      'frecuencia respiratoria',
      frecuenciaRespiratoriaMin,
      frecuenciaRespiratoriaMax,
    );
    final sistolica = entero(
      _sistolicaController,
      'presión sistólica',
      sistolicaMin,
      sistolicaMax,
    );
    final diastolica = entero(
      _diastolicaController,
      'presión diastólica',
      diastolicaMin,
      diastolicaMax,
    );
    final saturacion = entero(
      _saturacionController,
      'saturación',
      saturacionMin,
      saturacionMax,
    );

    double? temperatura;
    final temperaturaTexto = _texto(_temperaturaController);
    if (temperaturaTexto != null) {
      final valor = double.tryParse(temperaturaTexto);
      if (valor == null || valor < temperaturaMin || valor > temperaturaMax) {
        fueraDeRango.add('temperatura');
      } else {
        temperatura = valor;
      }
    }

    // ── Validación clínica de la presión ──
    var presionValida = true;
    if (sistolica != null && diastolica != null && diastolica >= sistolica) {
      presionValida = false;
    }

    // ── Resultados, cada uno debajo de su campo ──
    var hayAlguno = false;
    setState(() {
      _borrarResultados();
      if (fc != null) {
        _resultadoFc = interpretarFrecuenciaCardiaca(fc, meses);
        hayAlguno = true;
      }
      if (fr != null) {
        _resultadoFr = interpretarFrecuenciaRespiratoria(fr, meses);
        hayAlguno = true;
      }
      if (presionValida && (sistolica != null || diastolica != null)) {
        _resultadoPresion = interpretarPresionArterial(
          sistolica: sistolica,
          diastolica: diastolica,
          meses: meses,
        );
        hayAlguno = true;
      }
      if (temperatura != null) {
        _resultadoTemperatura = interpretarTemperatura(temperatura);
        hayAlguno = true;
      }
      if (saturacion != null) {
        _resultadoSaturacion = interpretarSaturacion(saturacion);
        hayAlguno = true;
      }
    });

    // Los avisos van después de dibujar: el resto de los signos sí se
    // interpretó y conviene que el usuario los vea junto con el aviso.
    if (fueraDeRango.isNotEmpty) {
      _avisar('Revisa estos valores: ${fueraDeRango.join(", ")}.');
    } else if (!presionValida) {
      _avisar('La presión diastólica debe ser menor que la sistólica.');
    } else if (!hayAlguno) {
      _avisar('Captura al menos un signo vital para interpretar.');
    }
  }

  void _limpiar() {
    for (final c in [
      _edadController,
      _fcController,
      _frController,
      _sistolicaController,
      _diastolicaController,
      _temperaturaController,
      _saturacionController,
    ]) {
      c.clear();
    }
    setState(_borrarResultados);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEdad(colorScheme, textTheme),
            const SizedBox(height: 20),
            // Los seis campos van en tres renglones de dos: son números de dos
            // o tres cifras y el ancho completo estaba desperdiciado. La
            // etiqueta de arriba lleva la abreviatura y el nombre completo se
            // conserva en el texto de ayuda del campo, que sigue visible
            // mientras se escribe.
            RenglonSignos(
              izquierda: CampoSigno(
                campo: NumericInputField(
                  label: "FC (lpm)",
                  textoAyuda: "lpm",
                  controller: _fcController,
                  focusNode: _fcFocus,
                  maxLength: 3,
                ),
                resultado: _resultadoFc,
              ),
              derecha: CampoSigno(
                campo: NumericInputField(
                  label: "FR (rpm)",
                  textoAyuda: "rpm",
                  controller: _frController,
                  focusNode: _frFocus,
                  maxLength: 2,
                ),
                resultado: _resultadoFr,
              ),
            ),
            const SizedBox(height: 20),
            // La presión es UN signo vital con DOS campos y UNA interpretación
            // conjunta, así que los dos campos y su pastilla comparten tarjeta,
            // y la pastilla abarca el renglón completo.
            TarjetaSigno(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RenglonSignos(
                    izquierda: NumericInputField(
                      label: "Sistólica",
                      textoAyuda: "mmHg",
                      controller: _sistolicaController,
                      focusNode: _sistolicaFocus,
                      maxLength: 3,
                    ),
                    derecha: NumericInputField(
                      label: "Diastólica",
                      textoAyuda: "mmHg",
                      controller: _diastolicaController,
                      focusNode: _diastolicaFocus,
                      maxLength: 3,
                    ),
                  ),
                  if (_resultadoPresion != null)
                    PastillaSigno(_resultadoPresion!),
                ],
              ),
            ),
            const SizedBox(height: 20),
            RenglonSignos(
              izquierda: CampoSigno(
                campo: NumericInputField(
                  label: "Temp (°C)",
                  textoAyuda: "Axilar",
                  controller: _temperaturaController,
                  focusNode: _temperaturaFocus,
                  maxLength: 4,
                  allowDecimal: true,
                ),
                resultado: _resultadoTemperatura,
              ),
              derecha: CampoSigno(
                campo: NumericInputField(
                  label: "SpO2 (%)",
                  textoAyuda: "%",
                  controller: _saturacionController,
                  focusNode: _saturacionFocus,
                  maxLength: 3,
                ),
                resultado: _resultadoSaturacion,
              ),
            ),
            const SizedBox(height: 20),
            BotonesSignos(onLimpiar: _limpiar, onInterpretar: _interpretar),
            // Reserva el alto real de la barra de navegación del sistema, de
            // gestos o de botones, más el aire de siempre. Se queda aunque la
            // pantalla quepa sin scroll: con el teclado abierto o con la fuente
            // del sistema aumentada el scroll vuelve, y es lo que evita que el
            // último elemento termine debajo de la barra.
            SizedBox(height: MediaQuery.paddingOf(context).bottom + 20),
          ],
        ),
      ),
    );
  }

  /// La edad va en su propio contenedor, con el mismo fondo que las tarjetas
  /// de los signos, para que no se lea como un campo suelto.
  ///
  /// El campo y el selector de unidad van lado a lado: apilados gastaban un
  /// renglón entero de una pantalla que ya pedía mucho scroll.
  Widget _buildEdad(ColorScheme colorScheme, TextTheme textTheme) {
    final contenido = Row(
      // Por abajo: el campo trae su etiqueta encima y el selector no, así que
      // alinearlos por arriba los dejaría desfasados.
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 2,
          child: NumericInputField(
            label: "Edad",
            textoAyuda: _unidad == UnidadEdad.anios ? "Años" : "Meses",
            controller: _edadController,
            focusNode: _edadFocus,
            maxLength: 3,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: OpcionSelector<UnidadEdad>(
            opciones: UnidadEdad.values,
            seleccionada: _unidad,
            etiqueta: (u) => u == UnidadEdad.anios ? "Años" : "Meses",
            onChanged: (u) => setState(() => _unidad = u),
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ThemeColors.tarjetaSobreFondo(context),
        borderRadius: BorderRadius.circular(30),
      ),
      child: contenido,
    );
  }
}

// ================== PESTAÑA DE INFORMACIÓN ==================
/// Tablas de referencia y la información de la escala.
///
/// Ninguna cifra de las tablas está escrita aquí: todas se generan de las
/// constantes de `signos_vitales_pediatricos.dart`, las mismas que usa la
/// interpretación. Si se corrige una constante, la tabla se actualiza sola.
class _InformacionLayout extends StatelessWidget {
  const _InformacionLayout();

  @override
  Widget build(BuildContext context) => InformacionSignosVitales(
    idEscala: "signos_vitales_pediatricos",
    tablas: _buildTablas(context),
  );

  List<Widget> _buildTablas(BuildContext context) {
    // El encabezado de cada categoría lleva el mismo relleno que la pastilla
    // de ese resultado en la pestaña de interpretación.
    Color color(NivelSigno nivel) => colorNivelSigno(context, nivel);

    final coloresFrecuencia = [
      null,
      color(NivelSigno.bajo),
      color(NivelSigno.normal),
      color(NivelSigno.leve),
      color(NivelSigno.moderada),
      color(NivelSigno.grave),
    ];

    List<List<String>> filasFrecuencia(List<RangoFrecuencia> tabla) => [
      for (final r in tabla)
        [
          etiquetaEdad(r.mesesMin, r.mesesMax),
          '${r.bajoMax}',
          '${r.bajoMax + 1} - ${r.normalMax}',
          '${r.normalMax + 1} - ${r.leveMax}',
          '${r.leveMax + 1} - ${r.moderadaMax}',
          '${r.moderadaMax + 1}',
        ],
    ];

    // La temperatura se captura con un decimal, así que la febrícula ocupa
    // de una décima arriba de lo normal a una décima abajo de la fiebre.
    String grados(double valor) => valor.toStringAsFixed(1);

    Widget seccion(String titulo, Widget tabla) =>
        SeccionTablaSigno(titulo: titulo, tabla: tabla);

    return [
      seccion(
        "Frecuencia cardiaca (lpm)",
        TablaReferencia(
          ajustarAlAncho: false,
          encabezados: const [
            "Edad",
            "Bradicardia (≤)",
            "Normal",
            "Leve",
            "Moderada",
            "Grave (≥)",
          ],
          coloresEncabezado: coloresFrecuencia,
          filas: filasFrecuencia(tablaFrecuenciaCardiaca),
        ),
      ),
      seccion(
        "Frecuencia respiratoria (rpm)",
        TablaReferencia(
          ajustarAlAncho: false,
          encabezados: const [
            "Edad",
            "Bradipnea (≤)",
            "Normal",
            "Leve",
            "Moderada",
            "Grave (≥)",
          ],
          coloresEncabezado: coloresFrecuencia,
          filas: filasFrecuencia(tablaFrecuenciaRespiratoria),
        ),
      ),
      seccion(
        "Presión arterial (mmHg)",
        TablaReferencia(
          ajustarAlAncho: false,
          encabezados: const [
            "Edad",
            "Hipotensión sist. (≤)",
            "Sistólica normal",
            "Diastólica normal",
            "HTA (≥)",
          ],
          coloresEncabezado: [
            null,
            color(NivelSigno.grave),
            color(NivelSigno.normal),
            color(NivelSigno.normal),
            color(NivelSigno.moderada),
          ],
          filas: [
            for (final r in tablaPresionArterial)
              [
                etiquetaEdad(r.mesesMin, r.mesesMax),
                '${r.hipotensionSistolicaMax}',
                '${r.sistolicaNormalMin} - ${r.sistolicaNormalMax}',
                '${r.diastolicaNormalMin} - ${r.diastolicaNormalMax}',
                '${r.hipertensionSistolica}/${r.hipertensionDiastolica}',
              ],
          ],
        ),
      ),
      seccion(
        "Temperatura axilar (°C)",
        TablaReferencia(
          encabezados: const ["Resultado", "°C"],
          filas: [
            [
              "Por debajo del rango normal",
              "< ${grados(temperaturaNormalMin)}",
            ],
            [
              "Normal",
              "${grados(temperaturaNormalMin)} - "
                  "${grados(temperaturaNormalMax)}",
            ],
            [
              "Febrícula",
              "${grados(temperaturaNormalMax + 0.1)} - "
                  "${grados(temperaturaFiebreMin - 0.1)}",
            ],
            ["Fiebre", "≥ ${grados(temperaturaFiebreMin)}"],
          ],
        ),
      ),
      seccion(
        "Saturación de oxígeno (%)",
        TablaReferencia(
          encabezados: const ["Resultado", "SpO2"],
          filas: [
            ["Normal", "≥ $saturacionNormalMin"],
            [
              "Desaturación leve",
              "$saturacionLeveMin - ${saturacionNormalMin - 1}",
            ],
            [
              "Desaturación moderada",
              "$saturacionModeradaMin - ${saturacionLeveMin - 1}",
            ],
            ["Desaturación severa", "≤ ${saturacionModeradaMin - 1}"],
          ],
        ),
      ),
    ];
  }
}
