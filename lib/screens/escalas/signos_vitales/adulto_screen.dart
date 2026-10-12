// lib/screens/escalas/signos_vitales/adulto_screen.dart
//
// Intérprete de signos vitales del adulto: cada signo se interpreta por
// separado, sin edad y sin sumar puntaje. Debajo de los campos van fichitas de
// consulta con valores de laboratorio.
//
// La lógica vive en utils/signos_vitales_adulto y las fichitas en
// utils/parametros_laboratorio_adulto. Las piezas visuales las comparte con la
// pantalla pediátrica (widgets/signos_vitales_comunes).
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../theme/theme_colors.dart';
import '../../../utils/parametros_laboratorio_adulto.dart';
import '../../../utils/signos_vitales_adulto.dart';
import '../../../utils/signos_vitales_pediatricos.dart';
import '../../../widgets/expandable_category_screen.dart';
import '../../../widgets/numeric_input_field.dart';
import '../../../widgets/opcion_selector.dart';
import '../../../widgets/signos_vitales_comunes.dart';
import '../../../widgets/tabbed_content.dart';
import '../../../widgets/tabla_referencia.dart';

class SignosVitalesAdultoScreen extends StatelessWidget {
  const SignosVitalesAdultoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "signos_vitales_adulto",
      // Partido en dos renglones por la misma razón que el pediátrico: la
      // barra no envuelve su Text y un título largo se desborda.
      title: "Signos vitales\ny parámetros",
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
  final _fcController = TextEditingController();
  final _frController = TextEditingController();
  final _sistolicaController = TextEditingController();
  final _diastolicaController = TextEditingController();
  final _temperaturaController = TextEditingController();
  final _saturacionController = TextEditingController();

  final _fcFocus = FocusNode();
  final _frFocus = FocusNode();
  final _sistolicaFocus = FocusNode();
  final _diastolicaFocus = FocusNode();
  final _temperaturaFocus = FocusNode();
  final _saturacionFocus = FocusNode();

  bool _epoc = false;

  /// Solo tiene efecto con [_epoc] activo; al apagar EPOC vuelve a false.
  bool _conOxigeno = false;

  ResultadoSigno? _resultadoFc;
  ResultadoSigno? _resultadoFr;
  ResultadoSigno? _resultadoPresion;
  ResultadoSigno? _resultadoTemperatura;
  ResultadoSigno? _resultadoSaturacion;

  List<TextEditingController> get _controllers => [
    _fcController,
    _frController,
    _sistolicaController,
    _diastolicaController,
    _temperaturaController,
    _saturacionController,
  ];

  List<FocusNode> get _focos => [
    _fcFocus,
    _frFocus,
    _sistolicaFocus,
    _diastolicaFocus,
    _temperaturaFocus,
    _saturacionFocus,
  ];

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
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focos) {
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
    for (final f in _focos) {
      f.unfocus();
    }

    // Los campos fuera de rango no generan pastilla y se nombran todos juntos
    // en un solo aviso, para no encimar varios SnackBar.
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

    final presionValida =
        sistolica == null || diastolica == null || diastolica < sistolica;

    var hayAlguno = false;
    setState(() {
      _borrarResultados();
      if (fc != null) {
        _resultadoFc = interpretarFrecuenciaCardiacaAdulto(fc);
        hayAlguno = true;
      }
      if (fr != null) {
        _resultadoFr = interpretarFrecuenciaRespiratoriaAdulto(fr);
        hayAlguno = true;
      }
      if (presionValida) {
        _resultadoPresion = interpretarPresionArterialAdulto(
          sistolica: sistolica,
          diastolica: diastolica,
        );
        if (_resultadoPresion != null) hayAlguno = true;
      }
      if (temperatura != null) {
        _resultadoTemperatura = interpretarTemperaturaAdulto(temperatura);
        hayAlguno = true;
      }
      if (saturacion != null) {
        _resultadoSaturacion = interpretarSaturacionAdulto(
          saturacion,
          epoc: _epoc,
          conOxigeno: _conOxigeno,
        );
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
    for (final c in _controllers) {
      c.clear();
    }
    setState(() {
      _borrarResultados();
      _epoc = false;
      _conOxigeno = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            // conjunta, así que comparten tarjeta y pastilla.
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
                debajoDelCampo: [
                  _buildInterruptor(
                    "Paciente con EPOC (meta $metaEpocTexto)",
                    _epoc,
                    (v) => setState(() {
                      _epoc = v;
                      if (!v) _conOxigeno = false;
                      // El resultado ya no corresponde a la escala elegida.
                      _resultadoSaturacion = null;
                    }),
                    textTheme,
                  ),
                  if (_epoc)
                    _buildInterruptor(
                      "Recibe oxígeno suplementario",
                      _conOxigeno,
                      (v) => setState(() {
                        _conOxigeno = v;
                        _resultadoSaturacion = null;
                      }),
                      textTheme,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            BotonesSignos(onLimpiar: _limpiar, onInterpretar: _interpretar),
            const SizedBox(height: 28),
            Text("Valores de laboratorio", style: textTheme.titleMedium),
            const SizedBox(height: 10),
            for (final parametro in parametrosLaboratorioAdulto)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FichitaLaboratorio(parametro),
              ),
            // Reserva el alto real de la barra de navegación del sistema, más
            // el aire de siempre, igual que la pantalla pediátrica.
            SizedBox(height: MediaQuery.paddingOf(context).bottom + 20),
          ],
        ),
      ),
    );
  }

  /// Etiqueta y selector No/Sí. Es el mismo [OpcionSelector] de Años/Meses
  /// del pediátrico, que ya tiene probado su contraste en los dos temas.
  Widget _buildInterruptor(
    String etiqueta,
    bool valor,
    ValueChanged<bool> onChanged,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta, style: textTheme.bodySmall),
          const SizedBox(height: 4),
          OpcionSelector<bool>(
            opciones: const [false, true],
            seleccionada: valor,
            etiqueta: (v) => v ? "Sí" : "No",
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Fichita de consulta de un valor de laboratorio. Cerrada muestra el nombre
/// y los valores; al tocarla despliega el detalle.
///
/// Toma el aspecto de los recuadros del glosario de Esenciales: mismo radio y
/// la misma reducción de fuente. El fondo es el de las tarjetas de signos. No
/// lleva color de alerta porque no interpreta nada, ni referencias: esas
/// viven en la pestaña de Información.
class _FichitaLaboratorio extends StatelessWidget {
  final ParametroLaboratorio parametro;

  const _FichitaLaboratorio(this.parametro);

  /// Lo mismo que `_reduccionGlosario` de la ficha de Esenciales.
  static const double _reduccion = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    TextStyle? reducido(TextStyle? base, double tamanoPorDefecto) => base
        ?.copyWith(fontSize: (base.fontSize ?? tamanoPorDefecto) - _reduccion);

    final desplegable = Theme(
      // Sin las líneas que ExpansionTile dibuja al abrirse, como el glosario.
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(
          PhosphorIconsRegular.testTube,
          color: colorScheme.onSurface,
        ),
        title: Text(
          parametro.nombre,
          style: reducido(textTheme.titleMedium, 25),
        ),
        subtitle: Text(
          parametro.valores.join('\n'),
          // El café claro del desglose del glosario.
          style: textTheme.titleMedium?.copyWith(
            fontSize: 17 - _reduccion,
            color: colorScheme.primary,
          ),
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 4),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        iconColor: colorScheme.onSurface,
        collapsedIconColor: colorScheme.onSurface,
        children: [
          Text(parametro.detalle, style: reducido(textTheme.bodySmall, 15)),
        ],
      ),
    );

    // No usa el tinte del glosario: aquel va sobre una tarjeta clara y aquí
    // la fichita va directo sobre el fondo de la pestaña, donde un tinte al
    // 8% no se distinguía (1.07:1). Lleva el mismo color que las tarjetas de
    // los signos.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: ThemeColors.tarjetaSobreFondo(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: desplegable,
    );
  }
}

// ================== PESTAÑA DE INFORMACIÓN ==================
/// Tablas de referencia generadas desde las constantes de
/// `signos_vitales_adulto.dart`, las mismas que usa la interpretación.
class _InformacionLayout extends StatelessWidget {
  const _InformacionLayout();

  @override
  Widget build(BuildContext context) => InformacionSignosVitales(
    idEscala: "signos_vitales_adulto",
    tablas: _buildTablas(),
  );

  List<Widget> _buildTablas() {
    // Rango de una categoría a partir de su límite inferior y el inferior de
    // la siguiente. La primera no tiene inferior y la última no tiene tope.
    String rangoPresion(List<int> limites, int i) {
      if (i == 0) return '< ${limites[1]}';
      if (i == limites.length - 1) return '≥ ${limites[i]}';
      return '${limites[i]} - ${limites[i + 1] - 1}';
    }

    String grados(double valor) => valor.toStringAsFixed(1);

    final etapa1 = CategoriaPresion.hipertension1.index;

    return [
      SeccionTablaSigno(
        titulo: "Presión arterial (mmHg)",
        tabla: TablaReferencia(
          encabezados: const ["Categoría", "Sistólica", "Diastólica"],
          filas: [
            ["Hipotensión", "≤ $hipotensionSistolicaMaxAdulto", ""],
            for (final c in CategoriaPresion.values)
              [
                c.etiqueta,
                rangoPresion(limitesSistolica, c.index),
                rangoPresion(limitesDiastolica, c.index),
              ],
            [
              "Hipertensión sistólica aislada",
              "≥ ${limitesSistolica[etapa1]}",
              "< ${limitesDiastolica[etapa1]}",
            ],
          ],
        ),
      ),
      SeccionTablaSigno(
        titulo: "Frecuencia cardiaca (lpm)",
        tabla: TablaReferencia(
          encabezados: const ["Resultado", "lpm"],
          filas: [
            ["Bradicardia grave", "≤ $fcBradicardiaGraveMaxAdulto"],
            [
              "Bradicardia leve",
              "${fcBradicardiaGraveMaxAdulto + 1} - "
                  "$fcBradicardiaLeveMaxAdulto",
            ],
            [
              "Normal",
              "${fcBradicardiaLeveMaxAdulto + 1} - $fcNormalMaxAdulto",
            ],
            [
              "Taquicardia leve",
              "${fcNormalMaxAdulto + 1} - $fcTaquicardiaLeveMaxAdulto",
            ],
            [
              "Taquicardia moderada",
              "${fcTaquicardiaLeveMaxAdulto + 1} - "
                  "$fcTaquicardiaModeradaMaxAdulto",
            ],
            ["Taquicardia grave", "≥ ${fcTaquicardiaModeradaMaxAdulto + 1}"],
          ],
        ),
      ),
      SeccionTablaSigno(
        titulo: "Frecuencia respiratoria (rpm)",
        tabla: TablaReferencia(
          encabezados: const ["Resultado", "rpm"],
          filas: [
            ["Bradipnea grave", "≤ $frBradipneaGraveMaxAdulto"],
            [
              "Bradipnea leve",
              "${frBradipneaGraveMaxAdulto + 1} - $frBradipneaLeveMaxAdulto",
            ],
            ["Normal", "${frBradipneaLeveMaxAdulto + 1} - $frNormalMaxAdulto"],
            [
              "Taquipnea moderada",
              "${frNormalMaxAdulto + 1} - $frTaquipneaModeradaMaxAdulto",
            ],
            ["Taquipnea grave", "≥ ${frTaquipneaModeradaMaxAdulto + 1}"],
          ],
        ),
      ),
      SeccionTablaSigno(
        titulo: "Temperatura (°C)",
        tabla: TablaReferencia(
          encabezados: const ["Resultado", "°C"],
          filas: [
            ["Hipotermia", "≤ ${grados(temperaturaHipotermiaMaxAdulto)}"],
            [
              "Por debajo del rango normal",
              "${grados(temperaturaHipotermiaMaxAdulto + 0.1)} - "
                  "${grados(temperaturaNormalMinAdulto - 0.1)}",
            ],
            [
              "Normal",
              "${grados(temperaturaNormalMinAdulto)} - "
                  "${grados(temperaturaNormalMaxAdulto)}",
            ],
            [
              "Fiebre",
              "${grados(temperaturaNormalMaxAdulto + 0.1)} - "
                  "${grados(temperaturaFiebreLeveMaxAdulto)}",
            ],
            [
              "Fiebre elevada",
              "≥ ${grados(temperaturaFiebreLeveMaxAdulto + 0.1)}",
            ],
          ],
        ),
      ),
      SeccionTablaSigno(
        titulo: "Saturación de oxígeno (%)",
        tabla: TablaReferencia(
          encabezados: const ["Resultado", "SpO2"],
          filas: [
            ["Normal", "≥ $spo2NormalMinAdulto"],
            [
              "Desaturación leve",
              "$spo2LeveMinAdulto - ${spo2NormalMinAdulto - 1}",
            ],
            [
              "Desaturación moderada",
              "$spo2ModeradaMinAdulto - ${spo2LeveMinAdulto - 1}",
            ],
            ["Desaturación severa", "≤ ${spo2ModeradaMinAdulto - 1}"],
          ],
        ),
      ),
    ];
  }
}
