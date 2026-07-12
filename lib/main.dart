// lib/main.dart

import 'package:flutter/material.dart';
import 'package:nursia_app/database/database_helper.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await DatabaseHelper.instance.database;
  final medicamentoRepo = MedicamentoRepository(MedicamentoDao(db));
  await medicamentoRepo.cargarSemillaSiHaceFalta();
  await DatabaseHelper.instance.cargarEscalasDesdeJSON();
  await DatabaseHelper.instance.cargarCalculadorasDesdeJSON();
  await DatabaseHelper.instance.cargarNormasDesdeJSON();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nursia',
      theme: AppTheme.lightTheme(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
