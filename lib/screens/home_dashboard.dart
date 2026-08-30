import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/grid_botones_dashboard.dart';
import '../widgets/home_nav_button.dart';
import '../widgets/tarjeta_desplegable.dart';
import '../utils/tips_helper.dart';
import 'esenciales/esenciales_screen.dart';
// Lo sigue usando BotonTurnoActivo, que se conserva aunque ya no se muestre.
import '../turno_activo/turno_activo_screen.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  /// Separación entre bloques y entre botones del grid. Es el mismo valor en
  /// toda la pantalla: si los huecos son iguales, no hay ninguno que resalte.
  static const double _espacio = 16;

  /// Margen mínimo entre el último bloque y la barra de navegación del
  /// sistema, sumado al inset real. Mismo criterio que `category_grid.dart`.
  static const double _margenInferiorMinimo = 12;

  /// Hueco superior para el TabBar que `home_screen.dart` dibuja flotando en
  /// un `Stack` encima del body. Es el único valor fijo que sobrevive: el
  /// dashboard no tiene forma de medir un widget que no es su ancestro, y es
  /// el mismo 98 que usan las otras cuatro pestañas.
  static const double _espacioTabBarFlotante = 98;

  @override
  Widget build(BuildContext context) {
    final botones = [
      const HomeNavButton(
        title: "Escalas",
        tabIndex: 0,
        icon: PhosphorIconsFill.chartBarHorizontal,
      ),
      const HomeNavButton(
        title: "Normativas",
        tabIndex: 4,
        icon: PhosphorIconsFill.bookOpen,
      ),
      const HomeNavButton(
        title: "Fármacos",
        tabIndex: 1,
        icon: PhosphorIconsFill.syringe,
      ),
      const HomeNavButton(
        title: "Calculadoras",
        tabIndex: 3,
        icon: PhosphorIconsFill.calculator,
      ),
    ];

    // SafeArea aparta la barra de navegación del sistema (de gestos o de
    // botones) y el padding inferior agrega el margen mínimo encima de ella.
    // Mismo patrón que category_grid.dart.
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          _espacioTabBarFlotante,
          16,
          _margenInferiorMinimo,
        ),
        child: Column(
          children: [
            // El grid es el único bloque elástico: absorbe la holgura que
            // dejan los tres bloques de abajo, que se miden solos. Flutter le
            // pasa como maxHeight lo que de verdad sobró, así que no hay nada
            // que estimar.
            Flexible(
              fit: FlexFit.loose,
              child: GridBotonesDashboard(botones: botones, espacio: _espacio),
            ),
            const SizedBox(height: _espacio),
            const BotonEsenciales(),
            const SizedBox(height: _espacio),
            const BotonProcedimientos(),
            const SizedBox(height: _espacio),
            const TipDelDia(),
          ],
        ),
      ),
    );
  }
}

// ================== BOTONES LARGOS ==================

/// Transición compartida por los botones largos: el mismo fade + scale que
/// usaba el botón de Turno Activo.
PageRouteBuilder _rutaConTransicion(Widget destino) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => destino,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var curve = Curves.easeInOutExpo;
      var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

      return FadeTransition(
        opacity: curvedAnimation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 2.0, end: 1).animate(curvedAnimation),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

/// Cáscara visual de los dos botones largos: mismas medidas y mismo look que
/// tenía BotonTurnoActivo (ancho completo, padding 20, primaryContainer,
/// radio 20, ícono en círculo a la izquierda y caret a la derecha).
class _BotonLargo extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _BotonLargo({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              radius: 20,
              child: Icon(icono, color: colorScheme.onPrimary, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              PhosphorIconsRegular.caretRight,
              color: Colors.white,
              size: 45,
            ),
          ],
        ),
      ),
    );
  }
}

class BotonEsenciales extends StatelessWidget {
  const BotonEsenciales({super.key});

  @override
  Widget build(BuildContext context) {
    return _BotonLargo(
      icono: PhosphorIconsFill.chalkboardTeacher,
      titulo: "Esenciales",
      subtitulo: "Referencia rápida",
      onTap: () =>
          Navigator.push(context, _rutaConTransicion(const EsencialesScreen())),
    );
  }
}

class BotonProcedimientos extends StatelessWidget {
  const BotonProcedimientos({super.key});

  @override
  Widget build(BuildContext context) {
    return _BotonLargo(
      icono: PhosphorIconsFill.chartPolar,
      titulo: "Procedimientos",
      subtitulo: "Próximamente",
      // Placeholder: el módulo todavía no existe.
      onTap: () => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text("Próximamente"))),
    );
  }
}

// ================== WIDGET TURNO ACTIVO ==================
// Retirado de la vista, pero se conserva completo (junto con su import de
// turno_activo_screen.dart) para poder reactivarlo agregándolo de nuevo al
// dashboard. La carpeta lib/turno_activo/, sus repositories y sus tablas
// siguen intactas.
class BotonTurnoActivo extends StatelessWidget {
  const BotonTurnoActivo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const TurnoActivoScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  var curve = Curves.easeInOutExpo;
                  var curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: curve,
                  );

                  return FadeTransition(
                    opacity: curvedAnimation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 2.0,
                        end: 1,
                      ).animate(curvedAnimation),
                      child: child,
                    ),
                  );
                },
            transitionDuration: const Duration(
              milliseconds: 400,
            ), // Duración ideal
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              radius: 20,
              child: Icon(
                PhosphorIconsFill.chartDonut,
                color: colorScheme.onPrimary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Turno Activo",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Pacientes | Pendientes | Medicamentos",
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              PhosphorIconsRegular.caretRight,
              color: Colors.white,
              size: 45,
            ),
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

    return TarjetaDesplegable(
      icono: PhosphorIconsFill.lightbulb,
      titulo: "Tip del día",
      // Expandida, el botón genera un tip nuevo en vez de colapsar
      accionTrailing: (context, expandido, alternar) => Tooltip(
        message: expandido ? "Siguiente tip" : "Ver tip",
        child: IconButton(
          onPressed: expandido ? _forzarNuevoTip : alternar,
          icon: Icon(
            expandido
                ? PhosphorIconsBold.arrowClockwise
                : PhosphorIconsRegular.caretDown,
            size: 20,
            color: colorScheme.primaryContainer,
          ),
        ),
      ),
      contenido: Text(
        _tipExhibido,
        style: textTheme.bodySmall?.copyWith(fontSize: 13),
      ),
    );
  }
}
