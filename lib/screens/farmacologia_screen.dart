// lib/screens/farmacologia_screen.dart
import 'package:flutter/material.dart';
import 'package:nursia_app/screens/farmacologia/antiinflamatorios.dart';
import 'package:nursia_app/screens/farmacologia/diureticos_screen.dart';
import 'package:nursia_app/screens/ficha_medicamento.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/category_grid.dart';
import '../widgets/searchable_screen.dart';
import 'farmacologia/analgesicos_screen.dart';
import 'farmacologia/anticoagulantes_screen.dart';
import 'farmacologia/antibioticos_screen.dart';
import 'farmacologia/cardiovascular_screen.dart';
import 'farmacologia/insulinas_screen.dart';
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
            "Anti-\ncoagulantes",
            PhosphorIconsRegular.drop,
            "anticoagulantes",
            const AnticoagulantesScreen(),
          ),
          _buildButton(
            "Insulinas",
            PhosphorIconsRegular.syringe,
            "insulinas",
            const InsulinasScreen(),
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

        return CategoryGrid(items: todasLasCategorias);
      },
    );
  }
}
