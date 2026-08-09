import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/home_nav_button.dart';
import '../widgets/tarjeta_desplegable.dart';
import '../utils/tips_helper.dart';
import 'esenciales/esenciales_screen.dart';
// Lo sigue usando BotonTurnoActivo, que se conserva aunque ya no se muestre.
import '../turno_activo/turno_activo_screen.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DINÁMICA DE BOTONES ---
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 1. Definimos los botones en una lista para manejarlos más fácil
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

    // 2. Calculamos el espacio disponible para los botones
    // Restamos padding superior (98), saludo (~60), espaciado (32) y el bloque inferior del Tip (~180)
    const double espacioFijoCaballete = 380;
    final double espacioDisponible = screenHeight - espacioFijoCaballete;

    // 3. Calculamos medidas para 3 filas (ya que son 5 botones)
    const double spacing = 16.0;
    final double anchoBoton =
        (screenWidth - 48) /
        2; // Pantalla - padding lateral (32) - espacio medio (16)

    // Queremos que quepan 3 filas exactamente
    final double altoTotalParaBotones = espacioDisponible - (2 * spacing);
    final double altoBotonIdeal = altoTotalParaBotones / 3;

    // 4. El ratio mágico
    double ratioDinamico = anchoBoton / altoBotonIdeal;

    // Si el ratio es demasiado bajo, ponemos un tope para que no se vean raros
    if (ratioDinamico < 1.2) ratioDinamico = 1.3;

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
                mainAxisAlignment: MainAxisAlignment
                    .start, // Cambiamos a start para controlar el flujo
                children: [
                  // BLOQUE SUPERIOR (Saludo + Botones)
                  Column(
                    children: [
                      // Saludo

                      // Grid de Botones Dinámico
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4, // Solo los primeros 4 botones (2 filas)
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: ratioDinamico,
                        ),
                        itemBuilder: (context, index) {
                          return botones[index];
                        },
                      ),
                      // Dos botones medianos de ancho igual, en el lugar que
                      // antes ocupaba el botón de Turno Activo.
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(child: BotonEsenciales()),
                          SizedBox(width: 16),
                          Expanded(child: BotonProcedimientos()),
                        ],
                      ),
                    ],
                  ),

                  // BLOQUE INFERIOR (El Tip)
                  // Al usar MainAxisAlignment.spaceBetween, este se irá al fondo
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
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

// ================== BOTONES MEDIANOS ==================

/// Transición compartida por los botones medianos: el mismo fade + scale que
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

/// Cáscara visual de los dos botones medianos: mismo look que tenía
/// BotonTurnoActivo (primaryContainer, radio 20, ícono en círculo), pero en
/// formato cuadrado para que quepan dos por renglón.
class _BotonMediano extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _BotonMediano({
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              radius: 20,
              child: Icon(icono, color: colorScheme.onPrimary, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontSize: 17,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: colorScheme.onPrimary,
              ),
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
    return _BotonMediano(
      icono: PhosphorIconsFill.bookmarkSimple,
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
    return _BotonMediano(
      icono: PhosphorIconsFill.listChecks,
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
