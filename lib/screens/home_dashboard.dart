import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/home_nav_button.dart';
import '../utils/tips_helper.dart';
import '../turno_activo/turno_activo_screen.dart';

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

    // --- LÓGICA DINÁMICA DE BOTONES ---
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 1. Definimos los botones en una lista para manejarlos más fácil
    final botones = [
      const HomeNavButton(
        title: "Escalas",
        tabIndex: 0,
        icon: PhosphorIconsRegular.clipboardText,
      ),
      const HomeNavButton(
        title: "Fármacos",
        tabIndex: 1,
        icon: PhosphorIconsRegular.pill,
      ),
      const HomeNavButton(
        title: "Calculadoras",
        tabIndex: 3,
        icon: PhosphorIconsRegular.calculator,
      ),
      const HomeNavButton(
        title: "Normativas",
        tabIndex: 4,
        icon: PhosphorIconsRegular.books,
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
                      const SizedBox(height: 16),

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
                      // Botón de Turno Activo (lo sacamos del grid para que sea ancho completo)
                      const SizedBox(height: 16),
                      const BotonTurnoActivo(),
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

// ================== WIDGET TURNO ACTIVO ==================
class BotonTurnoActivo extends StatelessWidget {
  const BotonTurnoActivo({super.key});

  @override
  Widget build(BuildContext context) {
    const Color cobreOscuro = Color(0xFF6F4225); // SaddleBrown
    const Color oroCobrizo = Color(0xFF904714); // Bronze/Copper Gold
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
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Configuramos una curva suave (Curves.easeOut es muy 'cremita')
              var curve = Curves.easeOutCubic;
              var curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: curve,
              );

              return FadeTransition(
                opacity: curvedAnimation,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 2.0,
                    end: 1.0,
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
          color: cobreOscuro,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              radius: 25,
              child: Icon(
                PhosphorIconsFill.star,
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
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    "Pacientes • Pendientes • Medicación",
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(PhosphorIconsBold.caretRight, color: Colors.white),
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
  bool _isExpanded = false;

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

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        // Reducimos el padding inferior cuando está colapsado
        padding: EdgeInsets.fromLTRB(12, 5, 12, _isExpanded ? 12 : 5),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hacemos que toda la cabecera sea clickable para expandir/colapsar
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(12),
              child: Row(
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
                    message: _isExpanded ? "Siguiente tip" : "Ver tip",
                    child: IconButton(
                      onPressed: _isExpanded
                          ? _forzarNuevoTip
                          : () => setState(() => _isExpanded = true),
                      icon: Icon(
                        _isExpanded
                            ? PhosphorIconsBold.arrowClockwise
                            : PhosphorIconsRegular.caretDown,
                        size: 20,
                        color: colorScheme.primaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Solo mostramos el contenido si está expandido
            if (_isExpanded) ...[
              const SizedBox(height: 8),
              Text(
                _tipExhibido,
                style: textTheme.bodySmall?.copyWith(fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
