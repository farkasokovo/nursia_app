// lib/screens/farmacologia_screen.dart
import 'package:flutter/material.dart';
import 'package:nursia_app/screens/farmacologia/antiinflamatorios.dart';
import 'package:nursia_app/screens/farmacologia/diureticos_screen.dart';
import 'package:nursia_app/screens/ficha_medicamento.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/category_button.dart';
import '../widgets/searchable_screen.dart';
import 'farmacologia/analgesicos_screen.dart';
import 'farmacologia/antibioticos_screen.dart';
import 'farmacologia/cardiovascular_screen.dart';
import '../repositories/repositorio_medicamentos.dart';
import '../models/medicamento.dart';

class FarmacologiaScreen extends StatefulWidget {
  const FarmacologiaScreen({super.key});

  @override
  State<FarmacologiaScreen> createState() => _FarmacologiaScreenState();
}

class _FarmacologiaScreenState extends State<FarmacologiaScreen> {
  List<Medicamento> _farmacos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarFarmacos();
  }

  Future<void> _cargarFarmacos() async {
    final medicamentos = await RepositorioMedicamentos.cargarMedicamentos();
    setState(() {
      _farmacos = medicamentos;
      _cargando = false;
    });
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

  void _navegarAFarmaco(Medicamento farmaco) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FichaMedicamento(nombreMedicamento: farmaco.nombre),
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

    // CAMBIO 1: Obtenemos la altura total de la pantalla del dispositivo
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SearchableScreen<Medicamento>(
      items: _farmacos,
      hintText: 'Buscar fármaco...',
      filterBy: (farmaco, query) =>
          farmaco.nombre.toLowerCase().contains(query),
      itemTitle: (farmaco) => farmaco.nombre,
      onItemTap: _navegarAFarmaco,
      emptyWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No se encontraron fármacos',
            style: textTheme.bodyLarge?.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Icon(
            PhosphorIconsThin.pill,
            size: 130,
            color: colorScheme.onTertiary,
          ),
          const SizedBox(height: 32),
        ],
      ),
      categoriesBuilder: (context) {
        final todasLasCategorias = [
          _buildButton(
            "Analgésicos",
            PhosphorIconsRegular.bandaids,
            "analgesicos",
            const AnalgesicosScreen(),
          ),
          _buildButton(
            "Antibióticos",
            PhosphorIconsRegular.shieldPlus,
            "antibioticos",
            const AntibioticosScreen(),
          ),
          _buildButton(
            "Anti-\nhipertensivos",
            PhosphorIconsRegular.heartbeat,
            "antihipertensivos",
            const CardiovascularScreen(),
          ),
          _buildButton(
            "Anti-\ninflamatorios",
            PhosphorIconsRegular.thermometer,
            "antiinflamatorios",
            const AntiinflamatoriosScreen(),
          ),
          _buildButton(
            "Diuréticos",
            PhosphorIconsRegular.drop,
            "diureticos",
            const DiureticosScreen(),
          ),
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
          _buildButton(
            "Próximamente",
            PhosphorIconsRegular.dotsThreeCircle,
            "proximamente5",
            null,
          ),
          _buildButton(
            "Próximamente",
            PhosphorIconsRegular.dotsThreeCircle,
            "proximamente6",
            null,
          ),
          _buildButton(
            "Próximamente",
            PhosphorIconsRegular.dotsThreeCircle,
            "proximamente7",
            null,
          ),
        ];

        // CAMBIO 2: Cambiamos de 6 a 8 botones por bloque
        final bloques = _chunkList(todasLasCategorias, 8);

        return SizedBox(
          height: screenHeight * 0.65,
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
                    childAspectRatio:
                        1.3, // Puedes ajustar esto si los botones se ven muy estirados o aplastados
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
