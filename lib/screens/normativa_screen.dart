import 'package:flutter/material.dart';
import 'package:nursia_app/database/database_helper.dart';
import 'package:nursia_app/models/norma.dart';
import 'package:nursia_app/screens/ficha_normativa_screen.dart';
import 'package:nursia_app/screens/lista_normas_filtrada_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/category_button.dart';
import '../widgets/searchable_screen.dart';

class NormativaScreen extends StatefulWidget {
  const NormativaScreen({super.key});

  @override
  State<NormativaScreen> createState() => _NormativaScreenState();
}

class _NormativaScreenState extends State<NormativaScreen> {
  List<Norma> _todasLasNormas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarNormas();
  }

  Future<void> _cargarNormas() async {
    // Pedimos TODAS las normas a la base de datos
    final normas = await DatabaseHelper.instance.obtenerTodasLasNormas();

    if (mounted) {
      setState(() {
        _todasLasNormas = normas;
        _cargando = false;
      });
    }
  }

  void _navegarAResultado(Norma norma) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FichaNormativaScreen(norma: norma),
      ),
    );
  }

  // --- LÓGICA DE PAGINACIÓN POR BLOQUES ---
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
      SnackBar(content: Text('La categoría "$nombre" aún está en desarrollo')),
    );
  }

  // ... (mismos imports de antes)

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SearchableScreen<Norma>(
      items: _todasLasNormas,
      hintText: 'Ej: "cateter", "NOM-019", "notas"...',
      filterBy: (norma, query) {
        final search = query.toLowerCase();
        return norma.codigo.toLowerCase().contains(search) ||
            norma.titulo.toLowerCase().contains(search) ||
            norma.palabrasClave.toLowerCase().contains(search);
      },
      itemTitle: (norma) => '${norma.codigo}: ${norma.tituloCorto}',
      onItemTap: _navegarAResultado,
      emptyWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No se encontraron normas',
            style: textTheme.bodyLarge?.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Icon(
            PhosphorIconsThin.books,
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
                "Práctica\nProfesional",
                PhosphorIconsRegular.userList,
                "n1",
                const ListaNormasFiltradaScreen(categoria: "Enfermería"),
              ),
              _buildButton(
                "Expediente\nClínico",
                PhosphorIconsRegular.folderOpen,
                "n2",
                null,
              ),
              _buildButton(
                "Infecciones\ny Riesgos",
                PhosphorIconsRegular.warningCircle,
                "n3",
                null,
              ),
              _buildButton(
                "Terapia de\nInfusión",
                PhosphorIconsRegular.drop,
                "n4",
                null,
              ),
              _buildButton(
                "Manejo de\nResiduos",
                PhosphorIconsRegular.trash,
                "n5",
                null,
              ),
              _buildButton(
                "Salud\nReproductiva",
                PhosphorIconsRegular.baby,
                "n6",
                null,
              ),
              _buildButton(
                "Próximamente",
                PhosphorIconsRegular.dotsThreeCircle,
                "p1",
                null,
              ),
              _buildButton(
                "Próximamente",
                PhosphorIconsRegular.dotsThreeCircle,
                "p2",
                null,
              ),
            ];

            // --- CAMBIOS PARA UNA SOLA COLUMNA ---
            const int botonesPorPagina = 4; // Ahora 4 por pantalla
            const double spacing = 16.0;
            final double espacioSuperiorEstimado = 280;
            final double espacioDisponible =
                screenHeight - espacioSuperiorEstimado;

            // El ancho ahora es casi toda la pantalla (menos paddings)
            final double anchoBoton = screenWidth - 32;

            // Queremos 4 filas, así que dividimos el espacio entre 4 (restando 3 espacios intermedios)
            final double altoTotalParaBotones =
                espacioDisponible - (3 * spacing);
            final double altoBotonIdeal = altoTotalParaBotones / 4;

            // Nuevo ratio para botones largos y horizontales
            double ratioDinamico = anchoBoton / altoBotonIdeal;

            final bloques = _chunkList(todasLasCategorias, botonesPorPagina);

            return SizedBox(
              height: espacioDisponible,
              child: PageView.builder(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemCount: bloques.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1, // <--- MAGIA: Una sola columna
                        mainAxisSpacing: spacing,
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

  // ...
}
