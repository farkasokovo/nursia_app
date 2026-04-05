import 'package:flutter/material.dart';
import 'package:nursia_app/screens/escalas/neurologicas/ramsay_screen.dart';
import 'package:nursia_app/screens/escalas/neurologicas/rass_screen.dart';
import 'package:nursia_app/screens/escalas/riesgos/downton_screen.dart';
import '../screens/escalas/neurologicas/glasgow_screen.dart';
// Cuando tengas más escalas, impórtalas aquí

//! PARA QUE SIRVA EL BUSCADOR, AGREGA TODAS LAS ESCALAS AQUI

final Map<String, WidgetBuilder> escalaRoutes = {
  'glasgow_screen': (context) => const GlasgowScreen(),
  'ramsay_screen': (context) => const RamsayScreen(),
  'rass_screen': (context) => const RassScreen(),
  'downton_screen': (context) => const DowntonScreen(),
  // 'rass_screen': (context) => const RassScreen(),
  // 'dowton_screen': (context) => const DowtonScreen(),
};
