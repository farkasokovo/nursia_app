import 'package:flutter/material.dart';
import '../screens/escalas/neurologicas/glasgow_screen.dart';
// Cuando tengas más escalas, impórtalas aquí

//! MAPA DE RUTAS (WIDGETBUILDER)

final Map<String, WidgetBuilder> escalaRoutes = {
  'glasgow_screen': (context) => const GlasgowScreen(),
  // 'ramsay_screen': (context) => const RamsayScreen(),
  // 'rass_screen': (context) => const RassScreen(),
  // 'dowton_screen': (context) => const DowtonScreen(),
};
