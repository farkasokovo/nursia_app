import 'package:flutter/material.dart';
import 'package:nursia_app/utils/icon_mapper.dart';
import '../models/medicamento.dart';
import '../repositories/repositorio_medicamentos.dart';

class FichaMedicamento extends StatefulWidget {
  final String nombreMedicamento;

  const FichaMedicamento({super.key, required this.nombreMedicamento});

  @override
  State<FichaMedicamento> createState() => _FichaMedicamentoState();
}

class _FichaMedicamentoState extends State<FichaMedicamento> {
  late Future<Medicamento?> _medicamentoFuture;

  @override
  void initState() {
    super.initState();
    _medicamentoFuture = RepositorioMedicamentos.obtenerPorNombre(
      widget.nombreMedicamento,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<Medicamento?>(
      future: _medicamentoFuture,
      builder: (context, snapshot) {
        final medicamento = snapshot.data;

        return Scaffold(
          backgroundColor: colorScheme.secondaryContainer,
          appBar: AppBar(
            title: Text(widget.nombreMedicamento),
            backgroundColor: colorScheme.primaryContainer,
            leading: medicamento != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Icon(
                      IconMapper.fromString(medicamento.icono),
                      size: 28,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  )
                : null,
          ),
          body: _buildBody(snapshot, colorScheme),
        );
      },
    );
  }

  Widget _buildBody(
    AsyncSnapshot<Medicamento?> snapshot,
    ColorScheme colorScheme,
  ) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final medicamento = snapshot.data!;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(context, "Presentación", medicamento.presentacion),
            const SizedBox(height: 16),
            _buildInfoRow(context, "Vía de administración", medicamento.via),
            const SizedBox(height: 16),
            _buildInfoRow(context, "Dosis adulto", medicamento.dosisAdulto),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              "Dosis pediátrica",
              medicamento.dosisPediatrica,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, "Máximo diario", medicamento.maximoDiario),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              "Contraindicaciones",
              medicamento.contraindicaciones,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, "Interacciones", medicamento.interacciones),
            const SizedBox(height: 16),
            _buildInfoRow(context, "Indicaciones", medicamento.indicaciones),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String titulo, String contenido) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          contenido.isEmpty ? "No especificado" : contenido,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSecondaryContainer,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
