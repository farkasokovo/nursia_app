// lib/screens/escalas_screen.dart
import 'package:flutter/material.dart';
import 'package:nursia_app/repositories/escala_repository.dart';
import 'package:nursia_app/screens/escalas/dolor_screen.dart';
import 'package:nursia_app/screens/escalas/emergencias_screen.dart';
import 'package:nursia_app/screens/escalas/neurologicas_screen.dart';
import 'package:nursia_app/screens/escalas/pediatricas_screen.dart';
import 'package:nursia_app/screens/escalas/riesgos_screen.dart';
import 'package:nursia_app/screens/escalas/signos_vitales_screen.dart';
import 'package:nursia_app/screens/escalas/valoracion_general_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../widgets/category_button.dart';
import '../widgets/category_grid.dart';
import '../widgets/searchable_screen.dart';
import '../models/escala_metadata.dart';
import '../utils/escala_routes.dart';

class EscalasScreen extends StatefulWidget {
  const EscalasScreen({super.key});

  @override
  State<EscalasScreen> createState() => _EscalasScreenState();
}

class _EscalasScreenState extends State<EscalasScreen> {
  /// Alto del botón de ancho completo que va arriba del grid.
  ///
  /// Arranca en el mismo piso que `CategoryGrid` usa para sus botones, así que
  /// no queda más bajo que una celda del grid aunque este se comprima. Al
  /// abarcar las dos columnas, su área es el doble que la de una celda.
  static const double _altoBotonAncho = 96.0;

  /// Separación entre el botón ancho y el grid. Coincide con el `_spacing`
  /// interno de `CategoryGrid`, para que el hueco se lea como uno más de la
  /// retícula y no como un salto aparte.
  static const double _separacionBotonAncho = 16.0;

  List<EscalaMetadata> _todasEscalas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEscalas();
  }

  Future<void> _cargarEscalas() async {
    final escalas = await context.read<EscalaRepository>().obtenerTodos();

    if (mounted) {
      setState(() {
        _todasEscalas = escalas;
        _cargando = false;
      });
    }
  }

  void _navegarAResultado(EscalaMetadata escala) {
    final builder = escalaRoutes[escala.ruta];
    if (builder != null) {
      Navigator.push(context, MaterialPageRoute(builder: builder));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pantalla de ${escala.nombre} no implementada')),
      );
    }
  }

  /// Crea los datos de un botón de categoría estandarizado
  CategoriaGridItem _buildButton(
    String title,
    IconData icon,
    String hero,
    Widget? target,
  ) {
    return CategoriaGridItem(
      titulo: title,
      icono: icon,
      heroTag: hero,
      onTap: target == null
          ? () => _mostrarNoImplementado(title)
          : () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => target),
            ),
    );
  }

  void _mostrarNoImplementado(String nombre) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('La sección de $nombre aún está en desarrollo')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SearchableScreen<EscalaMetadata>(
      items: _todasEscalas,
      hintText: 'Buscar escala...',
      searchableFields: (escala) => [escala.nombre],
      itemTitle: (escala) => escala.nombre,
      onItemTap: _navegarAResultado,
      emptyWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No se encontraron escalas',
            style: textTheme.bodyLarge?.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Icon(
            PhosphorIconsThin.clipboardText,
            size: 130,
            color: colorScheme.onTertiary,
          ),
          const SizedBox(height: 32),
        ],
      ),
      categoriesBuilder: (context) {
        final todasLasCategorias = [
          _buildButton(
            "Consciencia\ny sedación",
            PhosphorIconsRegular.brain,
            "neurologicas",
            const NeurologicasScreen(),
          ),
          _buildButton(
            "Valoración\nde riesgos",
            PhosphorIconsRegular.shieldCheck,
            "riesgos",
            const RiesgosScreen(),
          ),

          _buildButton(
            "Emergencias\ny Triaje",
            PhosphorIconsRegular.siren,
            "emergencias",
            const EmergenciasScreen(),
          ),
          _buildButton(
            "Evaluación\ndel Dolor",
            PhosphorIconsRegular.smileyNervous,
            "dolor",
            const DolorScreen(),
          ),
          _buildButton(
            "Pediátricas\ny Neonatales",
            PhosphorIconsRegular.baby,
            "pediatricas",
            const PediatricasScreen(),
          ),
          // _buildButton(
          //   "Próximamente",
          //   PhosphorIconsRegular.dotsThreeCircle,
          //   "proximamente1",
          //   null,
          // ),
          // _buildButton(
          //   "Próximamente",
          //   PhosphorIconsRegular.dotsThreeCircle,
          //   "proximamente2",
          //   null,
          // ),
          // _buildButton(
          //   "Próximamente",
          //   PhosphorIconsRegular.dotsThreeCircle,
          //   "proximamente3",
          //   null,
          // ),
          // _buildButton(
          //   "Próximamente",
          //   PhosphorIconsRegular.dotsThreeCircle,
          //   "proximamente4",
          //   null,
          // ),
        ];

        // "Signos Vitales" NO va dentro del grid: CategoryGrid usa un
        // childAspectRatio único para todas sus celdas, así que no admite una
        // celda del doble de ancho sin reescribir su cálculo. En vez de eso
        // sale del grid y ocupa su propia fila de ancho completo arriba.
        //
        // El Expanded es indispensable: CategoryGrid mide el alto que le da su
        // padre y tiene un assert que exige que sea acotado. Al recibir menos,
        // sus botones se reajustan solos, que es lo que ya hace.
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: _altoBotonAncho,
              child: CategoryButton(
                title: "Signos Vitales",
                icon: PhosphorIconsRegular.heartbeat,
                heroTag: "signos_vitales",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignosVitalesScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: _separacionBotonAncho),
            Expanded(
              child: CategoryGrid(
                items: todasLasCategorias,
                // 6 y no el valor por omisión de 8: CategoryGrid deriva el
                // número de filas de itemsPorPagina, no de los ítems reales
                // del bloque, así que con 8 reservaba alto para una cuarta
                // fila que aquí nunca se dibuja (5 categorías más el
                // placeholder son 6 celdas en 3 filas) y los títulos de dos
                // renglones se cortaban por unos pocos píxeles.
                itemsPorPagina: 6,
              ),
            ),
          ],
        );
      },
    );
  }
}
