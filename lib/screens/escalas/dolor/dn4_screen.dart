import 'package:flutter/material.dart';
import 'package:nursia_app/repositories/escala_repository.dart';
import 'package:nursia_app/widgets/estructura_ver_mas_screen.dart';
import 'package:nursia_app/widgets/scale_result_footer.dart';
import 'package:provider/provider.dart';
import '../../../widgets/scale_parameter_selector.dart';
import '../../../theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../widgets/molde_escalas_screen.dart';
import '../../../utils/scale_result_formatter.dart';

class ScaleValue {
  final int? score;
  const ScaleValue(this.score);
}

class Dn4Screen extends StatelessWidget {
  const Dn4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoldeEscalasScreen(
      heroTag: "dn4",
      title: "DN4",
      icon: PhosphorIconsFill.lightning,
      scaleTab: const _Dn4Layout(),
      infoTab: const _Dn4Info(),
    );
  }
}

class _Dn4Layout extends StatefulWidget {
  const _Dn4Layout();

  @override
  State<_Dn4Layout> createState() => _Dn4LayoutState();
}

class _Dn4LayoutState extends State<_Dn4Layout> {
  // Interrogatorio (7 ítems)
  ScaleValue? quemazon;
  ScaleValue? frioDoloroso;
  ScaleValue? descargas;
  ScaleValue? hormigueo;
  ScaleValue? alfileres;
  ScaleValue? entumecimiento;
  ScaleValue? picazon;
  // Examen físico (3 ítems)
  ScaleValue? hipoestesiaTacto;
  ScaleValue? hipoestesiaPinchazo;
  ScaleValue? alodinia;

  bool get _todoCompleto =>
      quemazon != null &&
      frioDoloroso != null &&
      descargas != null &&
      hormigueo != null &&
      alfileres != null &&
      entumecimiento != null &&
      picazon != null &&
      hipoestesiaTacto != null &&
      hipoestesiaPinchazo != null &&
      alodinia != null;

  int get _puntajeTotal {
    int total = 0;
    total += quemazon?.score ?? 0;
    total += frioDoloroso?.score ?? 0;
    total += descargas?.score ?? 0;
    total += hormigueo?.score ?? 0;
    total += alfileres?.score ?? 0;
    total += entumecimiento?.score ?? 0;
    total += picazon?.score ?? 0;
    total += hipoestesiaTacto?.score ?? 0;
    total += hipoestesiaPinchazo?.score ?? 0;
    total += alodinia?.score ?? 0;
    return total;
  }

  String get resultado {
    return ScaleResultFormatter.formatWithNV(
      parameters: {
        "Quemazón": quemazon?.score,
        "Frío doloroso": frioDoloroso?.score,
        "Descargas eléctricas": descargas?.score,
        "Hormigueo": hormigueo?.score,
        "Alfileres y agujas": alfileres?.score,
        "Entumecimiento": entumecimiento?.score,
        "Picazón": picazon?.score,
        "Hipoestesia al tacto": hipoestesiaTacto?.score,
        "Hipoestesia al pinchazo": hipoestesiaPinchazo?.score,
        "Alodinia al roce": alodinia?.score,
      },
    );
  }

  // Genera un selector binario Sí (1) / No (0) para un ítem del DN4.
  Widget _itemBinario(
    String title,
    String descSi,
    void Function(int?) onChanged,
  ) {
    return ScaleParameterSelector(
      title: title,
      onChanged: onChanged,
      options: [
        ScaleOption(score: 1, label: "Sí", description: descSi),
        const ScaleOption(
          score: 0,
          label: "No",
          description: "Ausente.",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ================== INTERROGATORIO ==================
                  _itemBinario(
                    "1. Quemazón",
                    "El dolor tiene sensación de quemazón.",
                    (v) => setState(() => quemazon = ScaleValue(v)),
                  ),
                  const SizedBox(height: 20),
                  _itemBinario(
                    "2. Frío doloroso",
                    "Sensación de frío doloroso en la zona.",
                    (v) => setState(() => frioDoloroso = ScaleValue(v)),
                  ),
                  const SizedBox(height: 20),
                  _itemBinario(
                    "3. Descargas eléctricas",
                    "El dolor se percibe como descargas eléctricas.",
                    (v) => setState(() => descargas = ScaleValue(v)),
                  ),
                  const SizedBox(height: 20),
                  _itemBinario(
                    "4. Hormigueo",
                    "Se asocia a hormigueo en la misma zona.",
                    (v) => setState(() => hormigueo = ScaleValue(v)),
                  ),
                  const SizedBox(height: 20),
                  _itemBinario(
                    "5. Alfileres y agujas",
                    "Sensación de pinchazos (alfileres y agujas).",
                    (v) => setState(() => alfileres = ScaleValue(v)),
                  ),
                  const SizedBox(height: 20),
                  _itemBinario(
                    "6. Entumecimiento",
                    "Adormecimiento o entumecimiento de la zona.",
                    (v) => setState(() => entumecimiento = ScaleValue(v)),
                  ),
                  const SizedBox(height: 20),
                  _itemBinario(
                    "7. Picazón",
                    "Picazón o comezón en la zona dolorosa.",
                    (v) => setState(() => picazon = ScaleValue(v)),
                  ),
                  const SizedBox(height: 20),

                  // ================== EXAMEN FÍSICO ==================
                  _itemBinario(
                    "8. Hipoestesia al tacto",
                    "Menor sensibilidad al roce en la zona dolorosa.",
                    (v) => setState(() => hipoestesiaTacto = ScaleValue(v)),
                  ),
                  const SizedBox(height: 20),
                  _itemBinario(
                    "9. Hipoestesia al pinchazo",
                    "Menor sensibilidad al pinchar la zona dolorosa.",
                    (v) => setState(() => hipoestesiaPinchazo = ScaleValue(v)),
                  ),
                  const SizedBox(height: 20),
                  _itemBinario(
                    "10. Alodinia al roce",
                    "El roce (cepillado suave) provoca o aumenta el dolor.",
                    (v) => setState(() => alodinia = ScaleValue(v)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        ScaleResultFooter(
          visible: _todoCompleto,
          resultado: resultado,
          colorResolver: (resultado) => _dn4Color(_puntajeTotal),
        ),
      ],
    );
  }
}

class _Dn4Info extends StatelessWidget {
  const _Dn4Info();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: FutureBuilder(
            future: context.read<EscalaRepository>().obtenerPorId("dn4"),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return EstructuraVerMasScreen(info: snapshot.data!);
            },
          ),
        ),
      ),
    );
  }
}

// Colores específicos del DN4 (punto de corte en ≥ 4/10)
Color _dn4Color(int puntajeTotal) {
  if (puntajeTotal >= 4) return AppColors.redAlertv3; // DN4 positivo
  return AppColors.withoutAlert; // DN4 negativo
}
