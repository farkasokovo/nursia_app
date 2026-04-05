// lib/screens/farmacologia_screen.dart
import 'package:flutter/material.dart';
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

  void _navegarAFarmaco(Medicamento farmaco) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FichaMedicamento(
          nombreMedicamento: farmaco.nombre, // 👈 Solo el nombre
        ),
      ),
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
      categoriesBuilder: (_) => SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CategoryButton(
                    title: "Analgésicos",
                    icon: PhosphorIconsRegular.bandaids,
                    heroTag: "analgesicos",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AnalgesicosScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CategoryButton(
                    title: "Antibióticos",
                    icon: PhosphorIconsRegular.shieldPlus,
                    heroTag: "antibioticos",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AntibioticosScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CategoryButton(
                    title: "Anti-\nhipertensivos",
                    icon: PhosphorIconsRegular.heartbeat,
                    heroTag: "antihipertensivos",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CardiovascularScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CategoryButton(
                    title: "Anti-\ninflamatorios",
                    icon: PhosphorIconsRegular.thermometer,
                    heroTag: "antiinflamatorios",
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
