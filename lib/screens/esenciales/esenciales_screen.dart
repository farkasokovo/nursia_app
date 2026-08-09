// lib/screens/esenciales/esenciales_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/ficha_esencial.dart';
import '../../repositories/esencial_repository.dart';
import '../../theme/app_theme.dart';
import '../../utils/categorias_esenciales.dart';
import '../../utils/esencial_icon_mapper.dart';
import '../../utils/search_utils.dart';
import '../../widgets/home_nav_button.dart';
import '../../widgets/tarjeta_desplegable.dart';
import 'ficha_esencial_screen.dart';

/// Índice de la pestaña casa. Las otras 4 las define
/// `utils/categorias_esenciales.dart`, que es la fuente única del nombre y el
/// ícono de cada categoría.
const int _tabCasa = 2;

/// Pantalla del módulo Esenciales: fichas de referencia rápida agrupadas en
/// 4 categorías, con una pestaña casa al centro a modo de dashboard.
///
/// A diferencia de `home_screen.dart`, aquí el TabBar NO flota en un Stack:
/// va en una Column junto con el buscador, porque el buscador tiene que
/// quedarse fijo entre el TabBar y el contenido en las 5 pestañas.
class EsencialesScreen extends StatefulWidget {
  const EsencialesScreen({super.key});

  @override
  State<EsencialesScreen> createState() => _EsencialesScreenState();
}

class _EsencialesScreenState extends State<EsencialesScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  /// TODAS las fichas, cargadas UNA sola vez aquí en el padre.
  ///
  /// Es la decisión central de la pantalla: si cada pestaña cargara lo suyo,
  /// el buscador (que es global y cruza las 4 categorías) se quedaría sin
  /// nada sobre qué buscar. Las pestañas reciben su sublista ya filtrada.
  List<FichaEsencial> _fichas = [];
  bool _cargando = true;

  String _busqueda = '';
  List<FichaEsencial> _resultados = [];

  @override
  void initState() {
    super.initState();
    _cargarFichas();
  }

  Future<void> _cargarFichas() async {
    final repo = context.read<EsencialRepository>();
    final fichas = await repo.obtenerTodos();
    if (!mounted) return;
    setState(() {
      _fichas = fichas;
      _cargando = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<FichaEsencial> _deCategoria(String categoria) =>
      _fichas.where((f) => f.categoria == categoria).toList();

  void _filtrar(String texto) {
    setState(() {
      _busqueda = texto;
      // La búsqueda es global: corre sobre la lista completa, no sobre la
      // pestaña activa. El ranking lo hace search_utils, igual que el resto
      // de los buscadores de la app.
      _resultados = texto.isEmpty
          ? const []
          : buscarYRankear<FichaEsencial>(
              items: _fichas,
              consulta: texto,
              camposBuscables: (f) => [
                f.titulo,
                f.tituloCorto,
                f.palabrasClave,
                f.resumen,
              ],
              titulo: (f) => f.titulo,
            );
    });
  }

  void _limpiar() {
    _searchController.clear();
    _filtrar('');
    _searchFocus.unfocus();
  }

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

  /// La ficha ya está en memoria, así que se pasa completa a la pantalla de
  /// detalle en vez de volver a consultarla en la BD.
  ///
  /// El unfocus va antes de navegar: si el teclado sigue abierto al empujar la
  /// ruta, regresa solo al volver de la ficha.
  void _abrirFicha(FichaEsencial ficha) {
    _searchFocus.unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FichaEsencialScreen(ficha: ficha)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DefaultTabController(
      length: 5,
      initialIndex: 2,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) Navigator.of(context).pop();
        },
        child: Scaffold(
          backgroundColor: colorScheme.secondary,
          appBar: AppBar(
            titleSpacing: 0,
            leading: IconButton(
              icon: Icon(
                PhosphorIconsBold.caretLeft,
                color: colorScheme.onPrimaryContainer,
                size: 32,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Esenciales',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: colorScheme.primaryContainer,
          ),
          body: Column(
            children: [
              _buildTabBar(colorScheme, textTheme),
              _buildBuscador(colorScheme),
              const SizedBox(height: 16),
              Expanded(child: _buildContenido(colorScheme, textTheme)),
            ],
          ),
        ),
      ),
    );
  }

  /// Fijo debajo del AppBar (no flotante). Comparte el fondo del AppBar para
  /// que se lea como una sola cabecera.
  Widget _buildTabBar(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      color: colorScheme.primaryContainer,
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        dividerColor: Colors.transparent,
        indicatorColor: colorScheme.onPrimaryContainer,
        labelColor: colorScheme.onPrimaryContainer,
        unselectedLabelColor: colorScheme.tertiaryContainer,
        labelStyle: textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          for (var i = 0; i < 5; i++)
            if (i == _tabCasa)
              const Tab(icon: PhosphorIcon(PhosphorIconsFill.house, size: 26))
            else
              Tab(text: categoriaPorTab(i)!.etiqueta),
        ],
      ),
    );
  }

  /// Mismo TextField que `widgets/searchable_screen.dart`, pero suelto: aquí
  /// el buscador y el contenido están separados por el TabBarView, así que no
  /// se puede usar aquel widget completo.
  Widget _buildBuscador(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onChanged: _filtrar,
        decoration: InputDecoration(
          hintText: 'Buscar en Esenciales...',
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
    );
  }

  Widget _buildContenido(ColorScheme colorScheme, TextTheme textTheme) {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    // Mientras haya texto, el TabBarView entero se oculta y se muestra una
    // lista única con los resultados de las 4 categorías juntas. El
    // TabController conserva su índice solo, así que al limpiar el buscador
    // se regresa a la pestaña donde estaba.
    if (_busqueda.isNotEmpty) {
      return _buildResultados(colorScheme, textTheme);
    }

    return TabBarView(
      children: [
        for (var i = 0; i < 5; i++)
          if (i == _tabCasa)
            _buildDashboard(colorScheme, textTheme)
          else
            _buildListaCategoria(categoriaPorTab(i)!, colorScheme, textTheme),
      ],
    );
  }

  Widget _buildListaCategoria(
    CategoriaEsencial categoria,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final fichas = _deCategoria(categoria.clave);
    if (fichas.isEmpty) {
      return _buildVacio(
        PhosphorIconsFill.folderOpen,
        'Todavía no hay fichas en ${categoria.etiqueta}.',
        colorScheme,
        textTheme,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: fichas.length,
      itemBuilder: (context, index) =>
          _buildTarjetaFicha(fichas[index], colorScheme, textTheme),
    );
  }

  Widget _buildResultados(ColorScheme colorScheme, TextTheme textTheme) {
    if (_resultados.isEmpty) {
      return _buildVacio(
        PhosphorIconsThin.listMagnifyingGlass,
        'No se encontraron fichas.',
        colorScheme,
        textTheme,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _resultados.length,
      itemBuilder: (context, index) => _buildTarjetaFicha(
        _resultados[index],
        colorScheme,
        textTheme,
        // En resultados el TabBar sigue resaltando otra pestaña, así que cada
        // ficha tiene que decir de qué categoría salió.
        mostrarCategoria: true,
      ),
    );
  }

  Widget _buildTarjetaFicha(
    FichaEsencial ficha,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    bool mostrarCategoria = false,
  }) {
    final resumen = Text(
      ficha.resumen,
      style: textTheme.bodySmall?.copyWith(
        fontSize: 13,
        color: colorScheme.onPrimary,
      ),
    );

    return Card(
      color: colorScheme.primary,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: PhosphorIcon(
          EsencialIconMapper.fromString(ficha.icono),
          size: 32,
          color: colorScheme.onPrimary,
        ),
        title: Text(ficha.tituloCorto, style: textTheme.titleSmall),
        subtitle: mostrarCategoria
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  _buildChipCategoria(ficha.categoria, colorScheme, textTheme),
                  const SizedBox(height: 6),
                  resumen,
                ],
              )
            : resumen,
        trailing: Icon(
          PhosphorIconsBold.caretRight,
          color: Colors.white54,
          size: 30,
        ),
        onTap: () => _abrirFicha(ficha),
      ),
    );
  }

  Widget _buildChipCategoria(
    String clave,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final categoria = categoriaPorClave(clave);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Si el JSON trae una categoría mal escrita, el chip degrada a solo
          // texto en vez de tronar.
          if (categoria != null) ...[
            PhosphorIcon(
              categoria.icono,
              size: 12,
              color: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 5),
          ],
          Text(
            categoria?.etiqueta ?? clave,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVacio(
    IconData icono,
    String mensaje,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 16),
            PhosphorIcon(icono, size: 130, color: colorScheme.onTertiary),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Pestaña casa (índice 2) ───────────────────────────────────────────

  Widget _buildDashboard(ColorScheme colorScheme, TextTheme textTheme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.15,
            children: [
              // Nombre, ícono y pestaña destino salen de categorias_esenciales;
              // ninguna categoría usa el índice 2 (esta misma pestaña).
              for (final categoria in categoriasEsenciales)
                HomeNavButton(
                  title: categoria.etiqueta,
                  tabIndex: categoria.tabIndex,
                  icon: categoria.icono,
                ),
            ],
          ),
          const SizedBox(height: 16),
          TarjetaDesplegable(
            icono: PhosphorIconsFill.info,
            titulo: 'Acerca de Esenciales',
            contenido: _buildAcercaDe(colorScheme, textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildAcercaDe(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final categoria in categoriasEsenciales)
          _buildRenglonCategoria(categoria, colorScheme, textTheme),
        const SizedBox(height: 12),
        _buildDescargo(colorScheme, textTheme),
      ],
    );
  }

  Widget _buildRenglonCategoria(
    CategoriaEsencial categoria,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: PhosphorIcon(
              categoria.icono,
              size: 16,
              color: colorScheme.primaryContainer,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${categoria.etiqueta}: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primaryContainer,
                    ),
                  ),
                  TextSpan(text: categoria.descripcion),
                ],
              ),
              style: textTheme.bodySmall?.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// greenAlert no vive dentro del ColorScheme, por eso se llama directo desde
  /// AppColors.
  Widget _buildDescargo(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.greenAlert,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhosphorIcon(
            PhosphorIconsFill.warningCircle,
            size: 20,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Esta información es de consulta rápida y no sustituye el '
              'protocolo de tu institución ni el criterio clínico. Ante '
              'cualquier duda, consulta la normativa vigente de tu unidad.',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
