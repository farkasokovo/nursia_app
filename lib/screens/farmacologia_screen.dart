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

  void _navegarAFarmaco(Medicamento farmaco) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FichaMedicamento(nombreMedicamento: farmaco.nombre),
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
        // Efecto de rebote estético
        physics: const BouncingScrollPhysics(),
        child: Padding(
          // Espacio al final para un scroll cómodo
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              _buildRow(
                leftTitle: "Analgésicos",
                leftIcon: PhosphorIconsRegular.bandaids,
                leftHero: "analgesicos",
                leftTarget: const AnalgesicosScreen(),

                rightTitle: "Antibióticos",
                rightIcon: PhosphorIconsRegular.shieldPlus,
                rightHero: "antibioticos",
                rightTarget: const AntibioticosScreen(),
              ),
              const SizedBox(height: 16),
              _buildRow(
                leftTitle: "Anti-\nhipertensivos",
                leftIcon: PhosphorIconsRegular.heartbeat,
                leftHero: "antihipertensivos",
                leftTarget: const CardiovascularScreen(),

                rightTitle: "Anti-\ninflamatorios",
                rightIcon: PhosphorIconsRegular.thermometer,
                rightHero: "antiinflamatorios",
                rightTarget: const AntiinflamatoriosScreen(),
              ),
              const SizedBox(height: 16),
              _buildSingleRow(
                title: "Diuréticos",
                icon: PhosphorIconsRegular.drop,
                hero: "diureticos",
                target: const DiureticosScreen(),
              ),
              // 👇 Cuando crees nuevas categorías de fármacos, solo agrégalas aquí:
              // const SizedBox(height: 16),
              // _buildRow(...),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper para construir filas de dos botones rápidamente
  Widget _buildRow({
    required String leftTitle,
    required IconData leftIcon,
    required String leftHero,
    required Widget? leftTarget,
    required String rightTitle,
    required IconData rightIcon,
    required String rightHero,
    required Widget? rightTarget,
  }) {
    return Row(
      children: [
        Expanded(
          child: CategoryButton(
            title: leftTitle,
            icon: leftIcon,
            heroTag: leftHero,
            onTap: leftTarget == null
                ? () => _mostrarNoImplementado(leftTitle)
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => leftTarget),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CategoryButton(
            title: rightTitle,
            icon: rightIcon,
            heroTag: rightHero,
            onTap: rightTarget == null
                ? () => _mostrarNoImplementado(rightTitle)
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => rightTarget),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleRow({
    required String title,
    required IconData icon,
    required String hero,
    required Widget? target,
  }) {
    return Row(
      children: [
        Expanded(
          child: CategoryButton(
            title: title,
            icon: icon,
            heroTag: hero,
            onTap: target == null
                ? () => _mostrarNoImplementado(title)
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => target),
                  ),
          ),
        ),
      ],
    );
  }

  /// Función para avisar que una pantalla aún no está terminada
  void _mostrarNoImplementado(String nombre) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('La sección de $nombre aún está en desarrollo')),
    );
  }
}
