// lib/screens/escalas_screen.dart
import 'package:flutter/material.dart';
import 'package:nursia_app/screens/escalas/neurologicas_screen.dart';
import 'package:nursia_app/screens/escalas/seguridad_screen.dart';
import 'package:nursia_app/screens/escalas/valoracion_screen.dart';
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
            PhosphorIconsThin.binoculars,
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
                    title: "Neurológicas",
                    icon: PhosphorIconsRegular.brain,
                    heroTag: "neurologicas",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NeurologicasScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CategoryButton(
                    title: "Seguridad\ndel paciente",
                    icon: PhosphorIconsRegular.shieldCheck,
                    heroTag: "seguridad",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SeguridadScreen(),
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
                    title: "Valoración clínica",
                    icon: PhosphorIconsRegular.stethoscope,
                    heroTag: "valoracion",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ValoracionScreen(),
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
