import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:nursia_app/turno_activo/models/paciente.dart';
import 'package:nursia_app/turno_activo/widgets/barra_acciones.dart';
import 'package:nursia_app/turno_activo/tabs/pacientes_tab.dart';

class TurnoActivoScreen extends StatefulWidget {
  const TurnoActivoScreen({super.key});

  @override
  State<TurnoActivoScreen> createState() => _TurnoActivoScreenState();
}

class _TurnoActivoScreenState extends State<TurnoActivoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> _medicamentosNombres = [];

  // Listas de registros
  final List<Paciente> _pacientes = [];
  final List<String> _pendientes = [];
  final List<String> _medicamentosTurno = [];

  // Estado de modo selección (compartido, se resetea al cambiar de tab)
  bool _modoSeleccion = false;
  final Set<int> _seleccionadosPacientes = {};
  final Set<int> _seleccionadosPendientes = {};
  final Set<int> _seleccionadosMedicamentos = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _cancelarSeleccion();
      }
    });
    _cargarMedicamentos();
  }

  Future<void> _cargarMedicamentos() async {
    final String response = await rootBundle.loadString(
      'assets/data/medicamentos.json',
    );
    final List<dynamic> data = json.decode(response);
    setState(() {
      _medicamentosNombres = data.map((m) => m['nombre'] as String).toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _cancelarSeleccion() {
    setState(() {
      _modoSeleccion = false;
      _seleccionadosPacientes.clear();
      _seleccionadosPendientes.clear();
      _seleccionadosMedicamentos.clear();
    });
  }

  void _eliminarSeleccionados() {
    final index = _tabController.index;
    setState(() {
      if (index == 0) {
        final sorted = _seleccionadosPacientes.toList()
          ..sort((a, b) => b.compareTo(a));
        for (final i in sorted) {
          _pacientes.removeAt(i);
        }
      } else if (index == 1) {
        final sorted = _seleccionadosPendientes.toList()
          ..sort((a, b) => b.compareTo(a));
        for (final i in sorted) {
          _pendientes.removeAt(i);
        }
      } else {
        final sorted = _seleccionadosMedicamentos.toList()
          ..sort((a, b) => b.compareTo(a));
        for (final i in sorted) {
          _medicamentosTurno.removeAt(i);
        }
      }
      _modoSeleccion = false;
      _seleccionadosPacientes.clear();
      _seleccionadosPendientes.clear();
      _seleccionadosMedicamentos.clear();
    });
  }

  Set<int> get _seleccionActual {
    switch (_tabController.index) {
      case 0:
        return _seleccionadosPacientes;
      case 1:
        return _seleccionadosPendientes;
      default:
        return _seleccionadosMedicamentos;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
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
        children: [
          // ── PESTAÑA 0: Pacientes ──────────────────────────────────────
          PacientesTab(
            pacientes: _pacientes,
            modoSeleccion: _modoSeleccion,
            seleccionados: _seleccionadosPacientes,
            onEntrarModoSeleccion: () => setState(() => _modoSeleccion = true),
            onCancelarSeleccion: _cancelarSeleccion,
            onToggleSeleccion: (index) => setState(() {
              if (_seleccionadosPacientes.contains(index)) {
                _seleccionadosPacientes.remove(index);
              } else {
                _seleccionadosPacientes.add(index);
              }
            }),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) newIndex -= 1;
                final moved = _pacientes.removeAt(oldIndex);
                _pacientes.insert(newIndex, moved);
              });
            },
          ),

          // ── PESTAÑA 1: Pendientes ─────────────────────────────────────
          // TODO: extraer a PendientesTab cuando tenga su propia lógica
          _buildTabContent(
            _pendientes,
            _seleccionadosPendientes,
            context,
            "Tareas Pendientes",
            "Control de procedimientos y cuidados pendientes por realizar.",
            PhosphorIconsRegular.listChecks,
          ),

          // ── PESTAÑA 2: Medicamentos ───────────────────────────────────
          // TODO: extraer a MedicamentosTab cuando tenga su propia lógica
          _buildTabContent(
            _medicamentosTurno,
            _seleccionadosMedicamentos,
            context,
            "Medicamentos del Turno",
            "Administración, registro y seguimiento de los fármacos indicados para tus pacientes durante el turno.",
            PhosphorIconsRegular.pill,
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
          : FloatingActionButton.extended(
              onPressed: () => _showAddDialog(context),
              icon: const Icon(PhosphorIconsRegular.plus),
              label: Text(_getFabLabel()),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
    );
  }

  String _getFabLabel() {
    switch (_tabController.index) {
      case 0:
        return "Nuevo Paciente";
      case 1:
        return "Nuevo Pendiente";
      case 2:
        return "Añadir Fármaco";
      default:
        return "Nuevo Registro";
    }
  }

  // ── SHOW ADD DIALOG ────────────────────────────────────────────────────────
  void _showAddDialog(BuildContext context) {
    final index = _tabController.index;

    if (index == 0) {
      _showAddPacienteDialog(context);
      return;
    }

    final controller = TextEditingController();
    String title = "";
    List<String> options = [];
    String label = "";

    if (index == 1) {
      title = "Añadir Tarea Pendiente";
      label = "Procedimiento o cuidado";
      options = [
        "Baño de esponja",
        "Cambio de vendajes",
        "Curación de catéter",
        "Control de líquidos",
        "Aspiración de secreciones",
        "Cambio de posición",
      ];
    } else {
      title = "Asignar Medicamento";
      label = "Nombre del fármaco";
      options = _medicamentosNombres;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return options.where((option) {
                  return option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              onSelected: (String selection) {
                setState(() {
                  if (index == 1) {
                    _pendientes.add(selection);
                  } else {
                    _medicamentosTurno.add(selection);
                  }
                });
                Navigator.pop(context);
              },
              fieldViewBuilder:
                  (context, fieldController, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: fieldController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: label,
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(
                          index == 1
                              ? PhosphorIconsRegular.listChecks
                              : PhosphorIconsRegular.pill,
                        ),
                      ),
                    );
                  },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      if (index == 1) {
                        _pendientes.add(text);
                      } else {
                        _medicamentosTurno.add(text);
                      }
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text("Confirmar Registro"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── DIÁLOGO PACIENTE ───────────────────────────────────────────────────────
  void _showAddPacienteDialog(BuildContext context) {
    final nombreController = TextEditingController();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Registrar Paciente",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  "Ingresa el nombre del paciente asignado a tu turno.",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nombreController,
                  textCapitalization: TextCapitalization.words,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Nombre completo",
                    hintText: "Ej: Juan Pérez García",
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(PhosphorIconsRegular.user),
                  ),
                  onSubmitted: (_) {
                    final nombre = nombreController.text.trim();
                    if (nombre.isNotEmpty) {
                      setState(() => _pacientes.add(Paciente(nombre: nombre)));
                      Navigator.pop(context);
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Cancelar"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final nombre = nombreController.text.trim();
                          if (nombre.isNotEmpty) {
                            setState(
                              () => _pacientes.add(Paciente(nombre: nombre)),
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Confirmar",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── TAB GENÉRICO (Pendientes / Medicamentos) ───────────────────────────────
  // Se extraerá a su propio archivo cuando cada pestaña tenga su lógica propia.
  Widget _buildTabContent(
    List<String> items,
    Set<int> seleccionados,
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (items.isEmpty) {
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

    return Column(
      children: [
        BarraAcciones(
          modoSeleccion: _modoSeleccion,
          totalItems: items.length,
          seleccionados: seleccionados.length,
          onEntrarModo: () => setState(() => _modoSeleccion = true),
          onCancelar: _cancelarSeleccion,
        ),
        Expanded(
          child: _modoSeleccion
              ? ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final estaSeleccionado = seleccionados.contains(index);

                    return GestureDetector(
                      onTap: () => setState(() {
                        if (estaSeleccionado) {
                          seleccionados.remove(index);
                        } else {
                          seleccionados.add(index);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 56,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: estaSeleccionado
                              ? colorScheme.error.withValues(alpha: 0.15)
                              : colorScheme.primaryContainer.withValues(
                                  alpha: 0.4,
                                ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: estaSeleccionado
                                ? colorScheme.error
                                : colorScheme.primaryContainer,
                            width: estaSeleccionado ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: estaSeleccionado
                                    ? colorScheme.error
                                    : Colors.transparent,
                                border: Border.all(
                                  color: estaSeleccionado
                                      ? colorScheme.error
                                      : colorScheme.outline.withValues(
                                          alpha: 0.5,
                                        ),
                                  width: 2,
                                ),
                              ),
                              child: estaSeleccionado
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                item,
                                style: textTheme.titleSmall?.copyWith(
                                  color: estaSeleccionado
                                      ? colorScheme.error
                                      : null,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: items.map((item) {
                      return Chip(
                        label: Text(item),
                        backgroundColor: colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => setState(() => items.remove(item)),
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }
}
