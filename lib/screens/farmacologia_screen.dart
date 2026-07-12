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
import '../models/medicamento.dart';
import 'package:nursia_app/repositories/medicamento_repository.dart';
import 'package:provider/provider.dart';

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
    final medicamentoRepo = context.read<MedicamentoRepository>();
    _cargarFarmacos(medicamentoRepo);
  }

  Future<void> _cargarFarmacos(MedicamentoRepository medicamentoRepo) async {
    final medicamentos = await medicamentoRepo.obtenerTodos();
    if (mounted) {
      setState(() {
        _farmacos = medicamentos;
        _cargando = false;
      });
    }
  }

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
        return OrientationBuilder(
          builder: (context, orientation) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

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
              // _buildButton(
              //   "Próximamente",
              //   PhosphorIconsRegular.dotsThreeCircle,
              //   "prox1",
              //   null,
              // ),
              // _buildButton(
              //   "Próximamente",
              //   PhosphorIconsRegular.dotsThreeCircle,
              //   "prox2",
              //   null,
              // ),
              // _buildButton(
              //   "Próximamente",
              //   PhosphorIconsRegular.dotsThreeCircle,
              //   "prox3",
              //   null,
              // ),
              // _buildButton(
              //   "Próximamente",
              //   PhosphorIconsRegular.dotsThreeCircle,
              //   "prox4",
              //   null,
              // ),
              // _buildButton(
              //   "Próximamente",
              //   PhosphorIconsRegular.dotsThreeCircle,
              //   "prox5",
              //   null,
              // ),
              // _buildButton(
              //   "Próximamente",
              //   PhosphorIconsRegular.dotsThreeCircle,
              //   "prox6",
              //   null,
              // ),
              // _buildButton(
              //   "Próximamente",
              //   PhosphorIconsRegular.dotsThreeCircle,
              //   "prox7",
              //   null,
              // ),
            ];

            // --- LÓGICA DINÁMICA ---
            const int botonesPorPagina = 8;
            const double spacing = 16.0;
            const double espacioSuperiorEstimado = 280;

            final double espacioDisponible =
                screenHeight - espacioSuperiorEstimado;
            final double anchoBoton = (screenWidth - 48) / 2;
            final double altoTotalParaBotones =
                espacioDisponible - (3 * spacing);
            final double altoBotonIdeal = altoTotalParaBotones / 4;

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
                    padding: const EdgeInsets.only(
                      bottom: 16,
                    ), // Tu padding de la victoria
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
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
