// lib/screens/farmacologia_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/category_button.dart';
import '../widgets/searchable_screen.dart';
import 'farmacologia/analgesicos_screen.dart';
import 'farmacologia/antibioticos_screen.dart';
import 'farmacologia/cardiovascular_screen.dart';

// Modelo temporal — reemplaza con el real cuando tengas el repositorio
class FarmacoMetadata {
  final String nombre;
  final String categoria;
  const FarmacoMetadata({required this.nombre, required this.categoria});
}

class FarmacologiaScreen extends StatefulWidget {
  const FarmacologiaScreen({super.key});

  @override
  State<FarmacologiaScreen> createState() => _FarmacologiaScreenState();
}

class _FarmacologiaScreenState extends State<FarmacologiaScreen> {
  List<FarmacoMetadata> _farmacos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarFarmacos();
  }

  Future<void> _cargarFarmacos() async {
    // TODO: reemplazar con tu repositorio real
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _farmacos = const [
        FarmacoMetadata(nombre: 'Paracetamol', categoria: 'Analgésico'),
        FarmacoMetadata(nombre: 'Ibuprofeno', categoria: 'Analgésico'),
        FarmacoMetadata(nombre: 'Amoxicilina', categoria: 'Antibiótico'),
        FarmacoMetadata(nombre: 'Metoprolol', categoria: 'Cardiovascular'),
      ];
      _cargando = false;
    });
  }

  void _navegarAFarmaco(FarmacoMetadata farmaco) {
    // TODO: navegar a la pantalla del fármaco
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${farmaco.nombre} — próximamente')));
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SearchableScreen<FarmacoMetadata>(
      items: _farmacos,
      hintText: 'Buscar fármaco...',
      filterBy: (farmaco, query) =>
          farmaco.nombre.toLowerCase().contains(query) ||
          farmaco.categoria.toLowerCase().contains(query),
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
                    icon: PhosphorIconsRegular.pill,
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
                    icon: PhosphorIconsRegular.virus,
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
                    title: "Antihipertensivos",
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
