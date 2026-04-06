// lib/screens/escalas_screen.dart
import 'package:flutter/material.dart';
import 'package:nursia_app/screens/escalas/neurologicas_screen.dart';
import 'package:nursia_app/screens/escalas/riesgos_screen.dart';
import 'package:nursia_app/screens/escalas/valoracion_general_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/category_button.dart';
import '../widgets/searchable_screen.dart';
import '../repositories/repositorio_escalas_metadata.dart';
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
    final escalas = await RepositorioEscalasMetadata.cargarEscalas();
    setState(() {
      _todasEscalas = escalas;
      _cargando = false;
    });
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

    // Obtenemos la altura total de la pantalla del dispositivo
    final screenHeight = MediaQuery.sizeOf(context).height;

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
            PhosphorIconsThin.binoculars,
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
            "Valoración\ngeneral",
            PhosphorIconsRegular.stethoscope,
            "clinica",
            const ValoracionGeneralScreen(),
          ),
          _buildButton(
            "TRIAGE y\nEmergencias",
            PhosphorIconsRegular.siren,
            "triage",
            null,
          ),
          _buildButton(
            "Valoración\ndel dolor",
            PhosphorIconsRegular.smileyNervous,
            "dolor",
            null,
          ),
          _buildButton(
            "Pediátricas\n/ Neonatales",
            PhosphorIconsRegular.baby,
            "neonatales",
            null,
          ),
          // Agregamos de relleno para completar los 8 y que veas el scroll
          _buildButton(
            "Próximamente",
            PhosphorIconsRegular.dotsThreeCircle,
            "proximamente1",
            null,
          ),
          _buildButton(
            "Próximamente",
            PhosphorIconsRegular.dotsThreeCircle,
            "proximamente2",
            null,
          ),
          _buildButton(
            "Próximamente",
            PhosphorIconsRegular.dotsThreeCircle,
            "proximamente3",
            null,
          ),
          _buildButton(
            "Próximamente",
            PhosphorIconsRegular.dotsThreeCircle,
            "proximamente4",
            null,
          ),
        ];

        // Dividimos en bloques de 8
        final bloques = _chunkList(todasLasCategorias, 8);

        return SizedBox(
          // Como pusiste un aspect ratio de 1.3 (los botones son más anchos que altos),
          // no ocuparán tanto espacio vertical. Con el 55% (0.55) de la pantalla debería bastar.
          height: screenHeight * 0.55,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemCount: bloques.length,
            itemBuilder: (context, index) {
              final botonesDelBloque = bloques[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columnas
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3, // El cambio que me pediste
                  ),
                  itemCount: botonesDelBloque.length,
                  itemBuilder: (context, i) => botonesDelBloque[i],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
