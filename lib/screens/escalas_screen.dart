// lib/screens/escalas_screen.dart
import 'package:flutter/material.dart';
import 'package:nursia_app/database/database_helper.dart';
import 'package:nursia_app/screens/escalas/neurologicas_screen.dart';
import 'package:nursia_app/screens/escalas/riesgos_screen.dart';
import 'package:nursia_app/screens/escalas/valoracion_general_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/category_button.dart';
import '../widgets/searchable_screen.dart';
import '../models/escala_metadata.dart';
import '../utils/escala_routes.dart';

class EscalasScreen extends StatefulWidget {
  const EscalasScreen({super.key});

  @override
  State<EscalasScreen> createState() => _EscalasScreenState();
}

class _EscalasScreenState extends State<EscalasScreen> {
  List<EscalaMetadata> _todasEscalas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEscalas();
  }

  Future<void> _cargarEscalas() async {
    // CAMBIO: Ahora pedimos los metadatos a SQLite
    final escalas = await DatabaseHelper.instance.obtenerEscalasMetadata();

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

  // --- LÓGICA DE PAGINACIÓN POR BLOQUES ---

  /// Divide una lista en sub-listas de un tamaño específico
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    return chunks;
  }

  /// Crea un botón de categoría estandarizado
  Widget _buildButton(
    String title,
    IconData icon,
    String hero,
    Widget? target,
  ) {
    return CategoryButton(
      title: title,
      icon: icon,
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
      filterBy: (escala, query) => escala.nombre.toLowerCase().contains(query),
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
        return OrientationBuilder(
          builder: (context, orientation) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

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
                "Valoración\ngeneral",
                PhosphorIconsRegular.stethoscope,
                "clinica",
                const ValoracionGeneralScreen(),
              ),
              // _buildButton(
              //   "TRIAGE y\nEmergencias",
              //   PhosphorIconsRegular.siren,
              //   "triage",
              //   null,
              // ),
              // _buildButton(
              //   "Valoración\ndel dolor",
              //   PhosphorIconsRegular.smileyNervous,
              //   "dolor",
              //   null,
              // ),
              // _buildButton(
              //   "Pediátricas\n/ Neonatales",
              //   PhosphorIconsRegular.baby,
              //   "neonatales",
              //   null,
              // ),
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

            // 1. Tu regla de oro: Siempre 8 botones por página
            const int botonesPorPagina = 8;
            const double spacing = 16.0;

            // 2. Calculamos el espacio disponible en pantalla
            final double espacioSuperiorEstimado =
                280; // Búsqueda, títulos, padding...
            final double espacioDisponible =
                screenHeight - espacioSuperiorEstimado;

            // 3. Calculamos el ancho exacto de 1 botón
            // Restamos 32 de padding de la pantalla (16 izq + 16 der) y 16 de en medio
            final double anchoBoton = (screenWidth - 48) / 2;

            // 4. Calculamos el alto IDEAL de 1 botón para que quepan exactamente 4 filas
            // Al espacio disponible le restamos los 3 huecos de separación entre las 4 filas (3 * 16 = 48)
            final double altoTotalParaBotones =
                espacioDisponible - (3 * spacing);
            final double altoBotonIdeal = altoTotalParaBotones / 4;

            // 5. ¡LA MAGIA DE TU IDEA! Calculamos el ratio dinámico
            double ratioDinamico = anchoBoton / altoBotonIdeal;

            // Dividimos siempre en bloques de 8
            final bloques = _chunkList(todasLasCategorias, botonesPorPagina);

            return SizedBox(
              height:
                  espacioDisponible, // Le damos todo el espacio libre que calculamos
              child: PageView.builder(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemCount: bloques.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsetsGeometry.only(bottom: 16),
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        // Aquí pasamos tu ratio calculado en lugar de un número fijo
                        childAspectRatio: ratioDinamico,
                      ),
                      itemCount: bloques[index].length,
                      itemBuilder: (context, i) => bloques[index][i],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
