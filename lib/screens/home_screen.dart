import 'package:flutter/material.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../utils/url_launcher_helper.dart';
import '../utils/verificador_actualizacion.dart';
import 'acerca_de_screen.dart';
import 'home_dashboard.dart';
import 'normativa_screen.dart';
import 'calculadora_screen.dart';
import 'escalas_screen.dart';
import 'farmacologia_screen.dart';
import 'sugerencias_screen.dart';

const List<Widget> _tabs = [
  Tab(text: "Escalas"),
  Tab(text: "Farmacología"),
  Tab(icon: PhosphorIcon(PhosphorIconsFill.house, size: 28)),
  Tab(text: "Calculadoras"),
  Tab(text: "Normativas"),
];

const List<Widget> _tabViews = [
  EscalasScreen(),
  FarmacologiaScreen(),
  HomeDashboard(),
  CalculadoraScreen(),
  NormativaScreen(),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<PackageInfo> _packageInfoFuture;

  // Info de una versión nueva, si la hay. Empieza en null (sin banner). El
  // banner solo aparece cuando la verificación remota confirma una versión
  // mayor. _bannerDescartado se activa con "Más tarde": oculta el banner SOLO
  // esta sesión (es un bool en memoria, no una preferencia persistente), así
  // que puede reaparecer en el próximo arranque de la app.
  InfoActualizacion? _infoActualizacion;
  bool _bannerDescartado = false;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();

    // La verificación corre DESPUÉS del primer frame para no bloquear ni
    // retrasar el arranque ni la interacción. Es completamente opcional: si
    // falla o no hay red, buscarActualizacion() devuelve null y no pasa nada.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarActualizacion();
    });
  }

  Future<void> _verificarActualizacion() async {
    final info = await buscarActualizacion();
    if (info != null && mounted) {
      setState(() => _infoActualizacion = info);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // ¿Hay teclado en pantalla? Es la única razón por la que esta pantalla
    // intercepta el botón atrás. Se mide con viewInsets, que es lo que el
    // sistema reserva para el teclado, y no con el árbol de foco: casi
    // siempre hay ALGÚN nodo enfocado dentro de un TabBarView aunque no haya
    // ningún campo de texto abierto, y esa condición tan laxa era la que
    // obligaba a presionar atrás cuatro veces para salir.
    //
    // Leerlo aquí (y no dentro del callback) es lo que permite usarlo en
    // `canPop`: el widget se reconstruye solo cuando el teclado aparece o
    // desaparece, así que el valor nunca queda viejo.
    final tecladoAbierto = MediaQuery.viewInsetsOf(context).bottom > 0;

    // Esta es la ruta raíz de la app. `canPop` es la única palanca que decide:
    // la ruta deja pasar el atrás solo cuando TODOS sus PopScope dicen que sí,
    // así que basta con que esta pantalla no bloquee para que el evento siga
    // su curso. Si ningún PopScope de la ruta bloquea (ni este ni el del
    // buscador de la pestaña activa), Flutter no encuentra nada que cerrar y
    // termina llamando a SystemNavigator.pop(): la app se minimiza al PRIMER
    // atrás, como el botón Home.
    //
    // No afecta la navegación interna: las escalas, medicamentos y la pantalla
    // de Esenciales se abren como rutas empujadas encima, y mientras una de
    // ellas está arriba este PopScope ni siquiera se consulta.
    return PopScope(
      canPop: !tecladoAbierto,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Único caso que esta pantalla atiende: cerrar el teclado. El resto
        // (limpiar el texto del buscador) lo resuelve el PopScope de
        // SearchableScreen, que recibe este mismo evento.
        if (tecladoAbierto) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: DefaultTabController(
        length: 5,
        initialIndex: 2,
        child: Scaffold(
          backgroundColor: colorScheme.secondary,
          extendBody: true,
          appBar: _buildAppBar(theme, colorScheme, textTheme),
          drawer: _buildDrawer(context, colorScheme, textTheme),
          body: Stack(
            children: [
              const TabBarView(children: _tabViews),
              Positioned(
                top: 15,
                left: 15,
                right: 15,
                child: _buildTabBar(theme, colorScheme, textTheme),
              ),
              // Banner de actualización: aparece centrado, sobre un scrim que
              // opaca (sin ocultar del todo) el resto de la pantalla. Solo se
              // construye si hay versión nueva y no fue descartado esta
              // sesión; si no, el Stack queda igual que antes.
              if (_infoActualizacion != null && !_bannerDescartado) ...[
                Positioned.fill(
                  child: GestureDetector(
                    // Absorbe los toques sobre el scrim: el contenido de
                    // atrás se ve, pero no es interactuable mientras el
                    // banner está abierto. Se cierra solo con sus botones.
                    onTap: () {},
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: _buildBannerActualizacion(
                      colorScheme,
                      textTheme,
                      _infoActualizacion!,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(
    ThemeData theme,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Nurska',
            style: textTheme.titleLarge?.copyWith(
              fontSize: 25,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          // Pastilla de notificación: solo aparece cuando hay una versión
          // nueva disponible (misma condición que el banner), pero a
          // diferencia del banner NO se puede descartar — no depende de
          // _bannerDescartado. Solo desaparece cuando la app se actualiza de
          // verdad (en el próximo arranque ya con la versión nueva
          // instalada, buscarActualizacion() ya no encuentra una versión
          // remota mayor y _infoActualizacion nunca se llena).
          if (_infoActualizacion != null) ...[
            const SizedBox(width: 16),
            _buildPildoraActualizacion(),
          ],
        ],
      ),
      backgroundColor: colorScheme.primaryContainer,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: PhosphorIcon(
            PhosphorIconsBold.list,
            color: colorScheme.onPrimaryContainer,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    );
  }

  Drawer _buildDrawer(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Drawer(
      backgroundColor: colorScheme.secondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(60)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDrawerHeader(colorScheme, textTheme),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildDrawerItem(
                    context: context,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    icon: PhosphorIconsBold.chatCircleDots,
                    title: 'Sugerencias',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SugerenciasScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDrawerItem(
                    context: context,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    icon: PhosphorIconsBold.info,
                    title: 'Acerca de',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AcercaDeScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            _buildDrawerFooter(colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIconsFill.heartbeat,
            size: 30,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nurska',
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                FutureBuilder<PackageInfo>(
                  future: _packageInfoFuture,
                  builder: (context, snapshot) {
                    final version = snapshot.data?.version;
                    return Text(
                      version == null ? 'Versión: ...' : 'Versión: $version',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.secondaryContainer,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        overlayColor: WidgetStateProperty.all(Colors.white24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                PhosphorIconsBold.caretRight,
                size: 25,
                color: colorScheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerFooter(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Icon(
            PhosphorIconsBold.wifiSlash,
            size: 16,
            color: colorScheme.onSecondary.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '100% local, sin conexión a internet',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSecondary.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerActualizacion(
    ColorScheme colorScheme,
    TextTheme textTheme,
    InfoActualizacion info,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greenAlert,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsBold.arrowCircleUp,
                size: 24,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Nueva versión disponible',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          if (info.notas.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              info.notas,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.85),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _bannerDescartado = true),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.8,
                  ),
                ),
                child: const Text('Más tarde', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => abrirUrl(context, info.urlDescarga),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.onPrimaryContainer,
                  foregroundColor: colorScheme.primaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  'Actualizar',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.greenAlert,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPildoraActualizacion() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => abrirUrl(context, _infoActualizacion!.urlDescarga),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.greenAlert,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(PhosphorIconsBold.arrowCircleUp, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Nueva versión',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(
    ThemeData theme,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        labelPadding: const EdgeInsets.symmetric(horizontal: 20),
        dividerColor: Colors.transparent,
        indicatorColor: colorScheme.onPrimaryContainer,
        labelColor: colorScheme.onPrimaryContainer,
        unselectedLabelColor: colorScheme.tertiaryContainer,
        labelStyle: textTheme.titleMedium?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.titleSmall?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        tabs: _tabs,
      ),
    );
  }
}
