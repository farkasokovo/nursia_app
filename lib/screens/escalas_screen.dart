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
        // Agregamos un efecto de rebote muy estético para iOS/Android
        physics: const BouncingScrollPhysics(),
        child: Padding(
          // Un padding abajo para que el último botón respire al hacer scroll
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              _buildRow(
                leftTitle: "Consciencia\ny sedación",
                leftIcon: PhosphorIconsRegular.brain,
                leftHero: "neurologicas",
                leftTarget: const NeurologicasScreen(),

                rightTitle: "Valoración\nde riesgos",
                rightIcon: PhosphorIconsRegular.shieldCheck,
                rightHero: "riesgos",
                rightTarget: const RiesgosScreen(),
              ),
              const SizedBox(height: 16),
              _buildRow(
                leftTitle: "Valoración\ngeneral",
                leftIcon: PhosphorIconsRegular.stethoscope,
                leftHero: "clinica",
                leftTarget: const ValoracionGeneralScreen(),

                rightTitle: "TRIAGE y\nEmergencias",
                rightIcon: PhosphorIconsRegular.siren,
                rightHero: "triage",
                // Dejamos en null las pantallas que aún no creas
                rightTarget: null,
              ),
              const SizedBox(height: 16),
              _buildRow(
                leftTitle: "Valoración\ndel dolor",
                leftIcon: PhosphorIconsRegular.smileyNervous,
                leftHero: "dolor",
                leftTarget: null,

                rightTitle: "Pediátricas\n/ Neonatales",
                rightIcon: PhosphorIconsRegular.baby,
                rightHero: "neonatales",
                rightTarget: null,
              ),
              // 👇 AQUÍ ABAJO PUEDES SEGUIR AGREGANDO FILAS CUANDO QUIERAS
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

  /// Función para avisar que una pantalla aún no está terminada
  void _mostrarNoImplementado(String nombre) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('La sección de $nombre aún está en desarrollo')),
    );
  }
}
