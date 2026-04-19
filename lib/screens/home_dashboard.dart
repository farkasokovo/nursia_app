import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/home_nav_button.dart';
import '../utils/tips_helper.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  Widget _getSaludo(BuildContext context) {
    final hour = DateTime.now().hour;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Creamos un estilo base para no repetir código
    final estiloTexto = textTheme.titleMedium;

    if (hour < 6) {
      return Row(
        children: [
          Text("Buenas noches", style: estiloTexto),
          const SizedBox(width: 8),
          Icon(PhosphorIconsFill.moon, color: colorScheme.primaryContainer),
        ],
      );
    }

    if (hour < 12) {
      return Row(
        children: [
          Text("Buenos días", style: estiloTexto),
          const SizedBox(width: 8),
          Icon(PhosphorIconsFill.sun, color: Colors.amberAccent, size: 30),
        ],
      );
    }

    if (hour < 20) {
      return Row(
        children: [
          Text("Buenas tardes", style: estiloTexto),
          const SizedBox(width: 8),
          Icon(PhosphorIconsFill.cloudSun, color: Colors.amber),
        ],
      );
    }

    return Row(
      children: [
        Text("Buenas noches", style: estiloTexto),
        const SizedBox(width: 8),
        Icon(PhosphorIconsFill.moonStars, color: Colors.indigoAccent),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            // Mantenemos tus paddings exactos
            padding: const EdgeInsets.fromLTRB(16, 98, 16, 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                // Esto obliga a la columna a medir al menos lo mismo que la pantalla
                minHeight:
                    constraints.maxHeight -
                    114, // Restamos el padding superior/inferior
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BLOQUE SUPERIOR (Saludo + Botones)
                  Column(
                    children: [
                      // Saludo
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: _getSaludo(context),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                "¿Qué necesitas consultar hoy?",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Botones
                      Row(
                        children: const [
                          Expanded(
                            child: HomeNavButton(
                              title: "Escalas",
                              tabIndex: 0,
                              icon: PhosphorIconsRegular.clipboardText,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: HomeNavButton(
                              title: "Fármacos",
                              tabIndex: 1,
                              icon: PhosphorIconsRegular.pill,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: const [
                          Expanded(
                            child: HomeNavButton(
                              title: "Calculadoras",
                              tabIndex: 3,
                              icon: PhosphorIconsRegular.calculator,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: HomeNavButton(
                              title: "Normativas",
                              tabIndex: 4,
                              icon: PhosphorIconsRegular.books,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // BLOQUE INFERIOR (El Tip)
                  // Al usar MainAxisAlignment.spaceBetween, este se irá al fondo
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: const TipDelDia(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ================== WIDGET TIP DEL DÍA ==================
class TipDelDia extends StatefulWidget {
  const TipDelDia({super.key});

  @override
  State<TipDelDia> createState() => _TipDelDiaState();
}

class _TipDelDiaState extends State<TipDelDia> {
  String _tipExhibido = "Cargando tip...";

  @override
  void initState() {
    super.initState();
    _cargarTipDeMemoria();
  }

  // Carga el tip que el Helper ya tiene guardado
  Future<void> _cargarTipDeMemoria() async {
    final tip = await TipsHelper.obtenerTipPersistente();
    if (mounted) {
      setState(() {
        _tipExhibido = tip;
      });
    }
  }

  // Fuerza al Helper a inventar uno nuevo
  Future<void> _forzarNuevoTip() async {
    final nuevoTip = await TipsHelper.generarNuevoTip();
    if (mounted) {
      setState(() {
        _tipExhibido = nuevoTip;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 5, 12, 12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsFill.lightbulb,
                size: 28,
                color: colorScheme.primaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                "Tip del día",
                style: textTheme.bodyLarge?.copyWith(fontSize: 18),
              ),
              const Spacer(),
              Tooltip(
                message: "Siguiente tip",
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed:
                      _forzarNuevoTip, // Llamamos a la función de cambio manual
                  icon: Icon(
                    PhosphorIconsBold.arrowClockwise,
                    size: 20,
                    color: colorScheme.primaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _tipExhibido,
            style: textTheme.bodySmall?.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
