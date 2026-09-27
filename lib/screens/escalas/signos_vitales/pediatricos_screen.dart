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
      title: "Signos vitales pediátricos",
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

/// Color de la pastilla según el peso clínico del resultado. Sigue la misma
/// gradación que la calculadora de PAM: verde para lo normal y la escala de
/// rojos conforme sube la gravedad.
Color _colorNivel(NivelSigno nivel) => switch (nivel) {
  NivelSigno.normal => AppColors.greenAlert,
  NivelSigno.bajo => AppColors.withoutAlert,
  NivelSigno.leve => AppColors.redAlertv1,
  NivelSigno.moderada => AppColors.redAlertv2,
  NivelSigno.grave => AppColors.redAlertv3,
  // Sin color de alerta: no hay nada que valorar todavía.
  NivelSigno.noValorable => AppColors.semiDarkPrimaryColor,
};

/// Un panel ya resuelto, listo para pintarse.
class _Panel {
  final String titulo;
  final ResultadoSigno resultado;

  const _Panel(this.titulo, this.resultado);
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

  /// Vacía hasta que se presiona "Interpretar".
  List<_Panel> _paneles = const [];

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
        setState(() => _paneles = const []);
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

    // ── Paneles, en el orden de los campos ──
    final paneles = <_Panel>[];
    if (fc != null) {
      paneles.add(
        _Panel('Frecuencia cardiaca', interpretarFrecuenciaCardiaca(fc, meses)),
      );
    }
    if (fr != null) {
      paneles.add(
        _Panel(
          'Frecuencia respiratoria',
          interpretarFrecuenciaRespiratoria(fr, meses),
        ),
      );
    }
    if (presionValida && (sistolica != null || diastolica != null)) {
      paneles.add(
        _Panel(
          'Presión arterial',
          interpretarPresionArterial(
            sistolica: sistolica,
            diastolica: diastolica,
            meses: meses,
          ),
        ),
      );
    }
    if (temperatura != null) {
      paneles.add(_Panel('Temperatura', interpretarTemperatura(temperatura)));
    }
    if (saturacion != null) {
      paneles.add(
        _Panel('Saturación de oxígeno', interpretarSaturacion(saturacion)),
      );
    }

    setState(() => _paneles = paneles);

    // Los avisos van después de dibujar: el resto de los signos sí se
    // interpretó y conviene que el usuario los vea junto con el aviso.
    if (fueraDeRango.isNotEmpty) {
      _avisar('Revisa estos valores: ${fueraDeRango.join(", ")}.');
    } else if (!presionValida) {
      _avisar('La presión diastólica debe ser menor que la sistólica.');
    } else if (paneles.isEmpty) {
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
    setState(() => _paneles = const []);
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
            NumericInputField(
              label: "Frecuencia cardiaca (lpm)",
              textoAyuda: "Latidos por minuto",
              controller: _fcController,
              focusNode: _fcFocus,
              maxLength: 3,
            ),
            const SizedBox(height: 20),
            NumericInputField(
              label: "Frecuencia respiratoria (rpm)",
              textoAyuda: "Respiraciones por minuto",
              controller: _frController,
              focusNode: _frFocus,
              maxLength: 2,
            ),
            const SizedBox(height: 20),
            NumericInputField(
              label: "Presión sistólica (mmHg)",
              textoAyuda: "Cifra sistólica",
              controller: _sistolicaController,
              focusNode: _sistolicaFocus,
              maxLength: 3,
            ),
            const SizedBox(height: 20),
            NumericInputField(
              label: "Presión diastólica (mmHg)",
              textoAyuda: "Cifra diastólica",
              controller: _diastolicaController,
              focusNode: _diastolicaFocus,
              maxLength: 3,
            ),
            const SizedBox(height: 20),
            NumericInputField(
              label: "Temperatura (°C)",
              textoAyuda: "Axilar",
              controller: _temperaturaController,
              focusNode: _temperaturaFocus,
              maxLength: 4,
              allowDecimal: true,
            ),
            const SizedBox(height: 20),
            NumericInputField(
              label: "Saturación de oxígeno (%)",
              textoAyuda: "SpO2",
              controller: _saturacionController,
              focusNode: _saturacionFocus,
              maxLength: 3,
            ),
            const SizedBox(height: 20),
            _buildBotones(colorScheme, textTheme),
            for (final panel in _paneles) ...[
              const SizedBox(height: 20),
              _buildPanel(panel, colorScheme, textTheme),
            ],
            // Reserva el alto real de la barra de navegación del sistema, de
            // gestos o de botones, más el aire de siempre. Sin esto el último
            // panel termina debajo de la barra. Es el mismo patrón que usa
            // scale_result_footer cuando todavía no hay resultado.
            SizedBox(height: MediaQuery.paddingOf(context).bottom + 20),
          ],
        ),
      ),
    );
  }

  /// La edad va dentro de un contenedor teñido para que no se lea como un
  /// signo vital más. El tinte se LEE de `NivelSeguridad.leve`, el mismo que
  /// usa `SeccionFichaView` para marcar una sección, en vez de copiar un color.
  Widget _buildEdad(ColorScheme colorScheme, TextTheme textTheme) {
    const nivel = NivelSeguridad.leve;
    final acento = nivel.colorAcento;

    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Datos del paciente",
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.primaryContainer,
            fontSize: 20 - nivel.reduccionTitulo,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        NumericInputField(
          label: "Edad",
          textoAyuda: _unidad == UnidadEdad.anios ? "En años" : "En meses",
          controller: _edadController,
          focusNode: _edadFocus,
          maxLength: 3,
        ),
        const SizedBox(height: 10),
        OpcionSelector<UnidadEdad>(
          opciones: UnidadEdad.values,
          seleccionada: _unidad,
          etiqueta: (u) => u == UnidadEdad.anios ? "Años" : "Meses",
          onChanged: (u) => setState(() => _unidad = u),
        ),
      ],
    );

    if (acento == null) return contenido;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: acento.withValues(alpha: nivel.opacidadFondo),
        borderRadius: BorderRadius.circular(10),
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
              overlayColor: colorScheme.primaryContainer,
              minimumSize: const Size(double.infinity, 60),
              side: BorderSide(color: colorScheme.primaryContainer, width: 2),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.defaultRadius,
              ),
            ),
            child: Text(
              "Limpiar",
              style: textTheme.titleSmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.primaryContainer,
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

  /// Panel de resultado. Es el de la calculadora de PAM sin el número grande y
  /// sin alto mínimo: con cinco apilados, cada uno tiene que ser compacto.
  Widget _buildPanel(
    _Panel panel,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: AppRadius.defaultRadius,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            "${panel.titulo}:",
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primaryContainer,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: _colorNivel(panel.resultado.nivel),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(
              panel.resultado.etiqueta,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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
            "Las tablas de referencia por grupo de edad llegan en una "
            "actualización futura.",
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
