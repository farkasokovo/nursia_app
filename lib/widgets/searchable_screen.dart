// lib/widgets/searchable_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Widget genérico de pantalla con buscador integrado.
///
/// Uso:
/// ```dart
/// SearchableScreen<EscalaMetadata>(
///   items: _todasEscalas,
///   filterBy: (escala, query) => escala.nombre.toLowerCase().contains(query),
///   hintText: 'Buscar escala...',
///   onItemTap: (escala) => _navegarA(escala),
///   itemTitle: (escala) => escala.nombre,
///   emptyWidget: Text('No se encontraron escalas'),
///   categoriesBuilder: (context) => _buildBotonesCategorias(),
/// )
/// ```
class SearchableScreen<T> extends StatefulWidget {
  /// Lista completa de items a buscar
  final List<T> items;

  /// Función que determina si un item coincide con la búsqueda
  final bool Function(T item, String query) filterBy;

  /// Texto placeholder del buscador
  final String hintText;

  /// Se ejecuta cuando el usuario toca un resultado
  final void Function(T item) onItemTap;

  /// Texto que se muestra en cada Card de resultado
  final String Function(T item) itemTitle;

  /// Widget que se muestra cuando no hay resultados
  final Widget emptyWidget;

  /// Builder del contenido principal (botones de categorías, etc.)
  /// Se muestra cuando el buscador está vacío
  final Widget Function(BuildContext context) categoriesBuilder;

  const SearchableScreen({
    super.key,
    required this.items,
    required this.filterBy,
    required this.hintText,
    required this.onItemTap,
    required this.itemTitle,
    required this.emptyWidget,
    required this.categoriesBuilder,
  });

  @override
  State<SearchableScreen<T>> createState() => _SearchableScreenState<T>();
}

class _SearchableScreenState<T> extends State<SearchableScreen<T>> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  List<T> _resultados = [];
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _resultados = widget.items;
  }

  // Si los items cambian desde afuera (carga async), actualiza los resultados
  @override
  void didUpdateWidget(SearchableScreen<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _resultados = widget.items;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _filtrar(String texto) {
    setState(() {
      _busqueda = texto;
      _resultados = texto.isEmpty
          ? widget.items
          : widget.items
                .where((item) => widget.filterBy(item, texto.toLowerCase()))
                .toList();
    });
  }

  void _limpiar() {
    _searchController.clear();
    _filtrar('');
    _searchFocus.unfocus();
  }

  /// Quita el foco antes de navegar — llama esto desde el padre antes de
  /// hacer Navigator.push para evitar que el teclado regrese al volver
  void unfocus() => _searchFocus.unfocus();

  Future<bool> _onWillPop() async {
    if (_busqueda.isNotEmpty) {
      _limpiar();
      return false;
    }
    if (_searchFocus.hasFocus) {
      _searchFocus.unfocus();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 150, 16, 16),
        child: Column(
          children: [
            // ── Buscador ──────────────────────────────────────────
            TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: _filtrar,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: colorScheme.onSecondaryContainer,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: PhosphorIcon(
                  PhosphorIconsBold.magnifyingGlass,
                  color: colorScheme.primaryContainer,
                ),
                suffixIcon: _busqueda.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: colorScheme.primaryContainer,
                        ),
                        onPressed: _limpiar,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: colorScheme.primaryContainer,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: colorScheme.primaryContainer,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),

            // ── Contenido principal ───────────────────────────────
            Expanded(
              child: _busqueda.isEmpty
                  ? widget.categoriesBuilder(context)
                  : _buildResultados(colorScheme, textTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultados(ColorScheme colorScheme, TextTheme textTheme) {
    if (_resultados.isEmpty) return widget.emptyWidget;

    return ListView.builder(
      itemCount: _resultados.length,
      itemBuilder: (context, index) {
        final item = _resultados[index];
        return Card(
          color: colorScheme.primary,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(widget.itemTitle(item), style: textTheme.titleSmall),
            trailing: Icon(
              PhosphorIconsBold.caretRight,
              color: Colors.white54,
              size: 30,
            ),
            onTap: () {
              _searchFocus.unfocus();
              widget.onItemTap(item);
            },
          ),
        );
      },
    );
  }
}
