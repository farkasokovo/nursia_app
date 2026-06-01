import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:nursia_app/database/database_helper.dart';
import 'package:nursia_app/turno_activo/models/paciente_turno.dart';
import 'package:nursia_app/turno_activo/models/pendiente_turno.dart';
import 'package:nursia_app/turno_activo/models/medicamento_turno.dart';
import 'package:nursia_app/turno_activo/tabs/pacientes_tab.dart';
import 'package:nursia_app/turno_activo/tabs/pendientes_tab.dart';
import 'package:nursia_app/turno_activo/tabs/medicamentos_tab.dart';
import 'package:nursia_app/turno_activo/widgets/add_px_dialog.dart';
import 'package:nursia_app/turno_activo/widgets/add_pend_dialog.dart';
import 'package:nursia_app/turno_activo/widgets/add_med_dialog.dart';

class TurnoActivoScreen extends StatefulWidget {
  const TurnoActivoScreen({super.key});

  @override
  State<TurnoActivoScreen> createState() => _TurnoActivoScreenState();
}

class _TurnoActivoScreenState extends State<TurnoActivoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── DATOS ──────────────────────────────────────────────────────────────────
  final List<Paciente> _pacientes = [];
  final List<PendienteInfo> _pendientes = [];
  final List<MedicamentoTurno> _medicamentos =
      []; // ← ahora tipado y persistente

  // ── MODO SELECCIÓN ─────────────────────────────────────────────────────────
  bool _modoSeleccion = false;
  final Set<int> _seleccionadosPacientes = {};
  final Set<int> _seleccionadosPendientes = {};
  final Set<int> _seleccionadosMedicamentos = {};

  Set<int> get _seleccionActual => switch (_tabController.index) {
    0 => _seleccionadosPacientes,
    1 => _seleccionadosPendientes,
    _ => _seleccionadosMedicamentos,
  };

  // ── CICLO DE VIDA ──────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _cancelarSeleccion();
    });
    _cargarDatosDeDB();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── CARGA INICIAL ──────────────────────────────────────────────────────────
  Future<void> _cargarDatosDeDB() async {
    await DatabaseHelper.instance.cargarCatalogoPendientesDesdeJSON();

    final listaPacientes = await DatabaseHelper.instance
        .obtenerPacientesTurno();
    final listaPendientes = await DatabaseHelper.instance
        .obtenerPendientesTurno();
    final listaMedicamentos = await DatabaseHelper.instance
        .obtenerMedicamentosTurno();

    setState(() {
      _pacientes
        ..clear()
        ..addAll(listaPacientes);
      _pendientes
        ..clear()
        ..addAll(listaPendientes);
      _medicamentos
        ..clear()
        ..addAll(listaMedicamentos);
    });
  }

  // ── MODO SELECCIÓN ─────────────────────────────────────────────────────────
  void _cancelarSeleccion() => setState(() {
    _modoSeleccion = false;
    _seleccionadosPacientes.clear();
    _seleccionadosPendientes.clear();
    _seleccionadosMedicamentos.clear();
  });

  void _eliminarSeleccionados() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          final sorted = _seleccionadosPacientes.toList()
            ..sort((a, b) => b.compareTo(a));
          for (final i in sorted) {
            final p = _pacientes[i];
            if (p.id != null) {
              DatabaseHelper.instance.eliminarPacienteTurno(p.id!);
            }
            _pacientes.removeAt(i);
          }
          DatabaseHelper.instance.actualizarOrdenPacientes(_pacientes);
          break;

        case 1:
          final sorted = _seleccionadosPendientes.toList()
            ..sort((a, b) => b.compareTo(a));
          for (final i in sorted) {
            final p = _pendientes[i];
            if (p.id != null) {
              DatabaseHelper.instance.eliminarPendienteTurno(p.id!);
            }
            _pendientes.removeAt(i);
          }
          DatabaseHelper.instance.actualizarOrdenPendientes(_pendientes);
          break;

        case 2:
          final sorted = _seleccionadosMedicamentos.toList()
            ..sort((a, b) => b.compareTo(a));
          for (final i in sorted) {
            final m = _medicamentos[i];
            if (m.id != null) {
              DatabaseHelper.instance.eliminarMedicamentoTurno(m.id!);
            }
            _medicamentos.removeAt(i);
          }
          DatabaseHelper.instance.actualizarOrdenMedicamentos(_medicamentos);
          break;
      }
      _cancelarSeleccion();
    });
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return PopScope(
      canPop: !_modoSeleccion,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _modoSeleccion) _cancelarSeleccion();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                controller: _tabController,
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
          controller: _tabController,
          physics: const ClampingScrollPhysics(parent: PageScrollPhysics()),
          dragStartBehavior: DragStartBehavior.start,
          children: [
            PacientesTab(
              pacientes: _pacientes,
              modoSeleccion: _modoSeleccion,
              seleccionados: _seleccionadosPacientes,
              onEntrarModoSeleccion: () =>
                  setState(() => _modoSeleccion = true),
              onCancelarSeleccion: _cancelarSeleccion,
              onToggleSeleccion: (i) => setState(() {
                _seleccionadosPacientes.contains(i)
                    ? _seleccionadosPacientes.remove(i)
                    : _seleccionadosPacientes.add(i);
              }),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  _pacientes.insert(newIndex, _pacientes.removeAt(oldIndex));
                });
                DatabaseHelper.instance.actualizarOrdenPacientes(_pacientes);
              },
              onAdd: () => showAddPacienteDialog(
                context,
                ordenSiguiente: _pacientes.length,
                onGuardado: (p) => setState(() => _pacientes.add(p)),
              ),
            ),
            PendientesTab(
              items: _pendientes,
              modoSeleccion: _modoSeleccion,
              seleccionados: _seleccionadosPendientes,
              onEntrarModoSeleccion: () =>
                  setState(() => _modoSeleccion = true),
              onCancelarSeleccion: _cancelarSeleccion,
              onToggleSeleccion: (i) => setState(() {
                _seleccionadosPendientes.contains(i)
                    ? _seleccionadosPendientes.remove(i)
                    : _seleccionadosPendientes.add(i);
              }),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  _pendientes.insert(newIndex, _pendientes.removeAt(oldIndex));
                });
                DatabaseHelper.instance.actualizarOrdenPendientes(_pendientes);
              },
              onAdd: () => showAddPendienteDialog(
                context,
                ordenSiguiente: _pendientes.length,
                onGuardado: (p) => setState(() => _pendientes.add(p)),
              ),
            ),
            MedicamentosTab(
              items: _medicamentos,
              modoSeleccion: _modoSeleccion,
              seleccionados: _seleccionadosMedicamentos,
              onEntrarModoSeleccion: () =>
                  setState(() => _modoSeleccion = true),
              onCancelarSeleccion: _cancelarSeleccion,
              onToggleSeleccion: (i) => setState(() {
                _seleccionadosMedicamentos.contains(i)
                    ? _seleccionadosMedicamentos.remove(i)
                    : _seleccionadosMedicamentos.add(i);
              }),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  _medicamentos.insert(
                    newIndex,
                    _medicamentos.removeAt(oldIndex),
                  );
                });
                DatabaseHelper.instance.actualizarOrdenMedicamentos(
                  _medicamentos,
                );
              },
              onAdd: () => showAddMedicamentoTurnoDialog(
                context,
                ordenSiguiente: _medicamentos.length,
                onGuardado: (m) => setState(() => _medicamentos.add(m)),
              ),
            ),
          ],
        ),
        floatingActionButton: _modoSeleccion
            ? FloatingActionButton.extended(
                onPressed: _seleccionActual.isEmpty
                    ? null
                    : _eliminarSeleccionados,
                icon: const Icon(PhosphorIconsRegular.trash),
                label: Text(
                  _seleccionActual.isEmpty
                      ? "Selecciona items"
                      : "Eliminar (${_seleccionActual.length})",
                  style: _seleccionActual.isEmpty
                      ? textTheme.bodyLarge
                      : textTheme.bodyLarge?.copyWith(
                          color: colorScheme.secondary,
                        ),
                ),
                backgroundColor: _seleccionActual.isEmpty
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.error,
                foregroundColor: _seleccionActual.isEmpty
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onError,
              )
            : null,
      ),
    );
  }
}
