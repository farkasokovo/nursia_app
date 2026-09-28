// lib/widgets/searchable_screen.dart
import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../utils/search_utils.dart';

/// Widget genérico de pantalla con buscador integrado.
///
/// Uso:
/// ```dart
/// SearchableScreen<EscalaMetadata>(
///   items: _todasEscalas,
///   searchableFields: (escala) => [escala.nombre],
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

  /// Campos buscables de un item, EN ORDEN DE PRIORIDAD.
  /// El índice 0 es el campo más relevante (p. ej. el código de la norma antes
  /// que su título). Se usan para rankear los resultados por relevancia.
  final List<String> Function(T item) searchableFields;

  /// Texto placeholder del buscador
  final String hintText;

  /// Se ejecuta cuando el usuario toca un resultado
  final void Function(T item) onItemTap;

  /// Texto que se muestra en cada Card de resultado
  final String Function(T item) itemTitle;

  /// Marca opcional que se dibuja debajo del título del resultado.
  ///
  /// Devuelve null para los items que no la llevan. Es opcional para no
  /// obligar a los módulos que no la necesitan (Escalas, Normativa); hoy la
  /// usa Farmacología para marcar los fármacos de alto riesgo, de modo que la
  /// advertencia aparezca también al buscar y no solo dentro de la categoría.
  final Widget? Function(T item)? itemBadge;

  /// Widget que se muestra cuando no hay resultados
  final Widget emptyWidget;

  /// Builder del contenido principal (botones de categorías, etc.)
  /// Se muestra cuando el buscador está vacío
  final Widget Function(BuildContext context) categoriesBuilder;

  const SearchableScreen({
    super.key,
    required this.items,
    required this.searchableFields,
    required this.hintText,
    required this.onItemTap,
    required this.itemTitle,
    required this.emptyWidget,
    required this.categoriesBuilder,
    this.itemBadge,
  });

  @override
  State<SearchableScreen<T>> createState() => _SearchableScreenState<T>();
}

class _SearchableScreenState<T> extends State<SearchableScreen<T>> {
  /// Aire entre la última tarjeta de resultados y la barra del sistema.
  ///
  /// Se suma al inset real de esa barra. Es un poco más que el margen mínimo de
  /// 12 que usan los grids porque aquí el último elemento es tocable y cae
  /// justo en el arco del pulgar; además nada más marca el final de la lista.
  /// Con las tarjetas aportando 6 de su propio margen, el último resultado
  /// queda a 22 px de la barra.
  static const double _aireInferior = 16;

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  List<T> _resultados = [];
  String _busqueda = '';

  /// Copia del estado del foco del buscador.
  ///
  /// Existe porque `canPop` del PopScope es un valor que se lee al construir,
  /// y `_searchFocus.hasFocus` cambia sin reconstruir el widget. Sin esta
  /// copia, el PopScope se quedaría con un `canPop` viejo justo en el momento
  /// en que el usuario abre el teclado y presiona atrás.
  bool _tieneFoco = false;

  @override
  void initState() {
    super.initState();
    _resultados = widget.items;
    _searchFocus.addListener(_alCambiarFoco);
  }

  void _alCambiarFoco() {
    if (_searchFocus.hasFocus != _tieneFoco) {
      setState(() => _tieneFoco = _searchFocus.hasFocus);
    }
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
    _searchFocus.removeListener(_alCambiarFoco);
    _searchFocus.dispose();
    super.dispose();
  }

  void _filtrar(String texto) {
    setState(() {
      _busqueda = texto;
      _resultados = texto.isEmpty ? widget.items : _buscarYRankear(texto);
    });
  }

  /// Delega en `buscarYRankear` de `utils/search_utils.dart`, que es la única
  /// implementación de la lógica de ranking (compartida con los buscadores que
  /// no usan este widget completo).
  List<T> _buscarYRankear(String texto) => buscarYRankear<T>(
    items: widget.items,
    consulta: texto,
    camposBuscables: widget.searchableFields,
    titulo: widget.itemTitle,
  );

  void _limpiar() {
    _searchController.clear();
    _filtrar('');
    _searchFocus.unfocus();
  }

  /// Quita el foco antes de navegar — llama esto desde el padre antes de
  /// hacer Navigator.push para evitar que el teclado regrese al volver
  void unfocus() => _searchFocus.unfocus();

  /// ¿El buscador tiene algo que cerrar antes de dejar salir de la app?
  ///
  /// Es lo que alimenta el `canPop` del PopScope, y con eso basta para que el
  /// botón atrás no salga de la app: la ruta solo deja pasar el evento cuando
  /// TODOS sus PopScope dicen que sí.
  bool get _tieneAlgoQueCerrar => _busqueda.isNotEmpty || _tieneFoco;

  /// Cierra lo que el buscador tenga abierto, en orden de prioridad.
  ///
  /// NO llama a `Navigator.pop()`. SearchableScreen no es una ruta empujada:
  /// vive dentro del TabBarView de la pantalla raíz, así que ese pop vaciaba
  /// el navegador y dejaba la app en pantalla negra sin cerrarla.
  void _manejarAtras() {
    if (_busqueda.isNotEmpty) {
      _limpiar();
      return;
    }
    if (_searchFocus.hasFocus) {
      _searchFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // `canPop` dinámico en vez de `false` fijo: este widget solo intercepta el
    // botón atrás cuando de verdad tiene algo que cerrar. Cuando no lo tiene,
    // deja de bloquear y el evento sigue su curso normal hasta el PopScope de
    // home_screen (o, si tampoco bloquea, hasta Android, que cierra la app).
    return PopScope(
      canPop: !_tieneAlgoQueCerrar,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _manejarAtras();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 98, 16, 0),
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
                  color: colorScheme.onSurface,
                ),
                suffixIcon: _busqueda.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: colorScheme.onSurface,
                        ),
                        onPressed: _limpiar,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: colorScheme.onSurface,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: colorScheme.onSurface,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: ThemeColors.campoBusqueda(context),
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
      // Aire inferior para que la última tarjeta no quede debajo de la barra de
      // navegación del sistema. El inset se consulta con `paddingOf`, que es lo
      // mismo que lee el `SafeArea` de `category_grid.dart`: reporta la barra
      // que todavía no ha apartado nadie, y se vuelve 0 cuando el teclado la
      // tapa, así al escribir en el buscador no se desperdicia media pantalla.
      //
      // Va como padding de la lista y no como `SafeArea` alrededor: así el
      // contenido sigue desplazándose por detrás de la barra (comportamiento
      // normal de Android), y lo único que cambia es dónde termina el scroll.
      padding: EdgeInsets.only(
        bottom: _aireInferior + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: _resultados.length,
      itemBuilder: (context, index) {
        final item = _resultados[index];
        final badge = widget.itemBadge?.call(item);
        return Card(
          color: colorScheme.primary,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(
              widget.itemTitle(item),
              style: textTheme.titleSmall?.copyWith(
                color: ThemeColors.tituloSobrePrimary(context),
              ),
            ),
            subtitle: badge == null
                ? null
                : Padding(padding: const EdgeInsets.only(top: 5), child: badge),
            trailing: Icon(
              PhosphorIconsBold.caretRight,
              color: ThemeColors.sobrePrimary(context, Colors.white54),
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
