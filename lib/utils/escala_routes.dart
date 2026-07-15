import 'package:flutter/material.dart';
import 'package:nursia_app/screens/escalas/dolor/dn4_screen.dart';
import 'package:nursia_app/screens/escalas/dolor/evna_screen.dart';
import 'package:nursia_app/screens/escalas/dolor/painad_screen.dart';
import 'package:nursia_app/screens/escalas/emergencias/indice_shock_screen.dart';
import 'package:nursia_app/screens/escalas/emergencias/mews_screen.dart';
import 'package:nursia_app/screens/escalas/emergencias/qsofa_screen.dart';
import 'package:nursia_app/screens/escalas/neurologicas/ramsay_screen.dart';
import 'package:nursia_app/screens/escalas/neurologicas/rass_screen.dart';
import 'package:nursia_app/screens/escalas/pediatricas/apgar_screen.dart';
import 'package:nursia_app/screens/escalas/pediatricas/flacc_screen.dart';
import 'package:nursia_app/screens/escalas/pediatricas/silverman_anderson_screen.dart';
import 'package:nursia_app/screens/escalas/riesgos/downton_screen.dart';
import 'package:nursia_app/screens/escalas/riesgos/maddox.dart';
import '../screens/escalas/neurologicas/glasgow_screen.dart';
// Cuando tengas más escalas, impórtalas aquí

//! PARA QUE SIRVA EL BUSCADOR, AGREGA TODAS LAS ESCALAS AQUI

final Map<String, WidgetBuilder> escalaRoutes = {
  'glasgow_screen': (context) => const GlasgowScreen(),
  'ramsay_screen': (context) => const RamsayScreen(),
  'rass_screen': (context) => const RassScreen(),
  'downton_screen': (context) => const DowntonScreen(),
  'maddox': (context) => const MaddoxScreen(),
  // Emergencias y Triaje
  'mews_screen': (context) => const MewsScreen(),
  'qsofa_screen': (context) => const QsofaScreen(),
  'indice_shock_screen': (context) => const IndiceShockScreen(),
  // Evaluación del Dolor
  'evna_screen': (context) => const EvnaScreen(),
  'painad_screen': (context) => const PainadScreen(),
  'dn4_screen': (context) => const Dn4Screen(),
  // Pediátricas y Neonatales
  'apgar_screen': (context) => const ApgarScreen(),
  'silverman_anderson_screen': (context) => const SilvermanAndersonScreen(),
  'flacc_screen': (context) => const FlaccScreen(),
};
