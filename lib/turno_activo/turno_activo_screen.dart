import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TurnoActivoScreen extends StatelessWidget {
  const TurnoActivoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Gestión de Turno"),
          leading: IconButton(
            icon: PhosphorIcon(
              PhosphorIconsBold.caretLeft,
              color: colorScheme.onPrimaryContainer,
              size: 32,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(72),
            child: Container(
              color: colorScheme.primaryContainer,
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorColor: colorScheme.onPrimaryContainer,
                labelColor: colorScheme.onPrimaryContainer,
                unselectedLabelColor: colorScheme.tertiaryContainer,
                labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                labelStyle: textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: textTheme.titleSmall?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(icon: Icon(PhosphorIconsFill.users), text: "Pacientes"),
                  Tab(
                    icon: Icon(PhosphorIconsFill.listChecks),
                    text: "Pendientes",
                  ),
                  Tab(icon: Icon(PhosphorIconsFill.pill), text: "Medicamentos"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildPlaceholder(
              context,
              "Mis Pacientes",
              "Aquí podrás gestionar la lista de pacientes asignados a tu servicio durante este turno.",
              PhosphorIconsRegular.users,
            ),
            _buildPlaceholder(
              context,
              "Tareas Pendientes",
              "Control de procedimientos y cuidados pendientes por realizar.",
              PhosphorIconsRegular.listChecks,
            ),
            _buildPlaceholder(
              context,
              "Medicamentos del Turno",
              "Administración, registro y seguimiento de los fármacos indicados para tus pacientes durante el turno.",
              PhosphorIconsRegular.pill,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(PhosphorIconsRegular.plus),
          label: const Text("Nuevo Registro"),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildPlaceholder(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
