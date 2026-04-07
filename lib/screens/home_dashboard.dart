import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/home_nav_button.dart';
import '../utils/tips_helper.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  String _getSaludo() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Buenos días 🌞";
    if (hour < 19) return "Buenas tardes 🌤️";
    return "Buenas noches 🌙";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 98, 16, 16),
        child: Column(
          children: [
            // Saludo
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _getSaludo(),
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primaryContainer,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    title: "Calculadoras",
                    tabIndex: 3,
                    icon: PhosphorIconsRegular.calculator,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(
                  child: HomeNavButton(
                    title: "Fármacos",
                    tabIndex: 1,
                    icon: PhosphorIconsRegular.pill,
                  ),
                ),

                SizedBox(width: 16),
                Expanded(
                  child: HomeNavButton(
                    title: "Más",
                    tabIndex: 4,
                    icon: PhosphorIconsRegular.dotsThreeCircle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Tip del día con botón "siguiente"
            const TipDelDia(),
          ],
        ),
      ),
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
  late Future<String> _tipFuture;

  @override
  void initState() {
    super.initState();
    _cargarNuevoTip();
  }

  void _cargarNuevoTip() {
    setState(() {
      _tipFuture = TipsHelper.obtenerTipAleatorio();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return FutureBuilder<String>(
      future: _tipFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final tip = snapshot.data!;
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
                      onPressed: _cargarNuevoTip,
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
              Text(tip, style: textTheme.bodySmall?.copyWith(fontSize: 13)),
            ],
          ),
        );
      },
    );
  }
}
