import 'package:flutter/material.dart';
import 'package:nursia_app/models/norma.dart';
import 'package:nursia_app/repositories/norma_repository.dart';
import 'package:nursia_app/screens/ficha_normativa_screen.dart';
import 'package:nursia_app/screens/lista_normas_screen.dart';
import 'package:nursia_app/widgets/expandable_category_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../widgets/category_grid.dart';
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
    final normas = await context.read<NormaRepository>().obtenerTodos();

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
      SnackBar(content: Text('La categoría "$nombre" aún está en desarrollo')),
    );
  }

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
        final todasLasCategorias = [
          _buildButton(
            "Práctica\nProfesional",
            PhosphorIconsRegular.userList,
            "n1", // Este tag DEBE coincidir con el del ExpandableCategoryScreen
            const ExpandableCategoryScreen(
              heroTag: "n1", // Aquí pasamos el tag para la animación
              title: "Práctica Profesional",
              icon: PhosphorIconsRegular.userList,
              child: ListaNormasFiltradaScreen(categoria: "Enfermería"),
            ),
          ),
          // _buildButton(
          //   "Expediente\nClínico",
          //   PhosphorIconsRegular.folderOpen,
          //   "n2",
          //   null,
          // ),
          // _buildButton(
          //   "Infecciones\ny Riesgos",
          //   PhosphorIconsRegular.warningCircle,
          //   "n3",
          //   null,
          // ),
          // _buildButton(
          //   "Terapia de\nInfusión",
          //   PhosphorIconsRegular.drop,
          //   "n4",
          //   null,
          // ),
          // _buildButton(
          //   "Manejo de\nResiduos",
          //   PhosphorIconsRegular.trash,
          //   "n5",
          //   null,
          // ),
          // _buildButton(
          //   "Salud\nReproductiva",
          //   PhosphorIconsRegular.baby,
          //   "n6",
          //   null,
          // ),
          // _buildButton(
          //   "Próximamente",
          //   PhosphorIconsRegular.dotsThreeCircle,
          //   "p1",
          //   null,
          // ),
          // _buildButton(
          //   "Próximamente",
          //   PhosphorIconsRegular.dotsThreeCircle,
          //   "p2",
          //   null,
          // ),
        ];

        // Una sola columna, botones largos y horizontales.
        return CategoryGrid(
          items: todasLasCategorias,
          crossAxisCount: 1,
          itemsPorPagina: 4,
        );
      },
    );
  }
}
