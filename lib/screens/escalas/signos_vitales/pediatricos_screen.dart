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

import '../../../theme/alert_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/secciones_ficha.dart';
import '../../../utils/signos_vitales_pediatricos.dart';
import '../../../widgets/expandable_category_screen.dart';
import '../../../widgets/numeric_input_field.dart';
import '../../../widgets/opcion_selector.dart';
import '../../../widgets/tabbed_content.dart';

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
        tabViews: [_InterpretacionLayout(), _InformacionPlaceholder()],
      ),
    );
  }
}

/// Gravedad clínica del resultado, en el vocabulario compartido de alertas.
/// Sigue la misma gradación que la calculadora de PAM: verde para lo normal y
/// la escala de rojos conforme sube la gravedad.
///
/// Devuelve null en `noValorable`, que NO es un nivel de alerta: no hay nada
/// que valorar todavía, así que no le toca ningún color de la escala clínica
/// sino el neutro de [_colorNivel].
NivelAlerta? _nivelAlerta(NivelSigno nivel) => switch (nivel) {
  NivelSigno.normal => NivelAlerta.verde,
  NivelSigno.bajo => NivelAlerta.sinAlerta,
  NivelSigno.leve => NivelAlerta.rojo1,
  NivelSigno.moderada => NivelAlerta.rojo2,
  NivelSigno.grave => NivelAlerta.rojo3,
  NivelSigno.noValorable => null,
};

/// Color de la pastilla. Es un relleno sólido con texto encima, así que le
/// toca la variante `fill`.
Color _colorNivel(BuildContext context, NivelSigno nivel) {
  final alerta = _nivelAlerta(nivel);
  if (alerta != null) return AlertColors.fill(context, alerta);
  return AlertColors.neutro(context);
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
            _buildRenglon(
              izquierda: _buildCampo(
                campo: NumericInputField(
                  label: "FC (lpm)",
                  textoAyuda: "lpm",
                  controller: _fcController,
                  focusNode: _fcFocus,
                  maxLength: 3,
                ),
                resultado: _resultadoFc,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              derecha: _buildCampo(
                campo: NumericInputField(
                  label: "FR (rpm)",
                  textoAyuda: "rpm",
                  controller: _frController,
                  focusNode: _frFocus,
                  maxLength: 2,
                ),
                resultado: _resultadoFr,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ),
            const SizedBox(height: 20),
            // La presión es UN signo vital con DOS campos y UNA interpretación
            // conjunta, así que los dos campos y su pastilla comparten tarjeta,
            // y la pastilla abarca el renglón completo.
            _buildTarjeta(
              colorScheme,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRenglon(
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
                    _buildPastilla(_resultadoPresion!, colorScheme, textTheme),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildRenglon(
              izquierda: _buildCampo(
                campo: NumericInputField(
                  label: "Temp (°C)",
                  textoAyuda: "Axilar",
                  controller: _temperaturaController,
                  focusNode: _temperaturaFocus,
                  maxLength: 4,
                  allowDecimal: true,
                ),
                resultado: _resultadoTemperatura,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              derecha: _buildCampo(
                campo: NumericInputField(
                  label: "SpO2 (%)",
                  textoAyuda: "%",
                  controller: _saturacionController,
                  focusNode: _saturacionFocus,
                  maxLength: 3,
                ),
                resultado: _resultadoSaturacion,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ),
            const SizedBox(height: 20),
            _buildBotones(colorScheme, textTheme),
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

  /// Dos campos lado a lado. Se alinean por arriba porque uno puede llevar
  /// pastilla y el otro no, y entonces tienen distinto alto.
  Widget _buildRenglon({required Widget izquierda, required Widget derecha}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: izquierda),
        const SizedBox(width: 12),
        Expanded(child: derecha),
      ],
    );
  }

  /// Tarjeta de un signo vital.
  ///
  /// Agrupa el campo (o los dos, en la presión) con su pastilla, para que se
  /// lea dónde termina un signo y empieza el siguiente. El color es el más
  /// claro del tema, de modo que queda una escala de tres tonos: el fondo de
  /// la pestaña es el más oscuro, la tarjeta el más claro y el campo, que tiene
  /// su propio relleno y su borde, queda en medio. El bloque de edad NO usa
  /// esta tarjeta: va teñido, y así sigue distinguiéndose de los signos.
  Widget _buildTarjeta(ColorScheme colorScheme, Widget hijo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: hijo,
    );
  }

  /// Un campo con su interpretación debajo, dentro de su tarjeta. La pastilla
  /// aparece donde el usuario ya estaba mirando, en vez de en un bloque al
  /// final de la pantalla.
  Widget _buildCampo({
    required Widget campo,
    required ResultadoSigno? resultado,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return _buildTarjeta(
      colorScheme,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          campo,
          if (resultado != null)
            _buildPastilla(resultado, colorScheme, textTheme),
        ],
      ),
    );
  }

  /// La pastilla de interpretación: compacta, de un renglón cuando el texto
  /// alcanza. Conserva el color por gravedad de la calculadora de PAM.
  Widget _buildPastilla(
    ResultadoSigno resultado,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: _colorNivel(context, resultado.nivel),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          resultado.etiqueta,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            // Crema en los dos temas. En claro `onPrimary` YA es crema y se
            // conserva tal cual; en oscuro ese mismo token es casi negro
            // (#241B14) y sobre el relleno oscuro caería a 1.92:1.
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColorsDark.ink
                : colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// La edad va dentro de un contenedor teñido para que no se lea como un
  /// signo vital más. El tinte se LEE de `NivelSeguridad.leve`, el mismo que
  /// usa `SeccionFichaView` para marcar una sección, en vez de copiar un color.
  ///
  /// El campo y el selector de unidad van lado a lado: apilados gastaban un
  /// renglón entero de una pantalla que ya pedía mucho scroll.
  Widget _buildEdad(ColorScheme colorScheme, TextTheme textTheme) {
    const nivel = NivelSeguridad.leve;
    final acento = nivel.colorAcento(context);

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

    if (acento == null) return contenido;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: contenido,
    );
  }

  Widget _buildBotones(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: _limpiar,
            style: OutlinedButton.styleFrom(
              overlayColor: colorScheme.onSurface,
              minimumSize: const Size(double.infinity, 60),
              side: BorderSide(color: colorScheme.onSurface, width: 2),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.defaultRadius,
              ),
            ),
            child: Text(
              "Limpiar",
              style: textTheme.titleSmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: _interpretar,
            style: ElevatedButton.styleFrom(
              overlayColor: colorScheme.tertiaryContainer,
              minimumSize: const Size(double.infinity, 60),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.defaultRadius,
              ),
            ),
            child: Text(
              "Interpretar",
              style: textTheme.titleSmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ================== PESTAÑA DE INFORMACIÓN ==================
/// Placeholder: las tablas de referencia se agregan en otra tarea.
class _InformacionPlaceholder extends StatelessWidget {
  const _InformacionPlaceholder();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "soon nigga",
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
