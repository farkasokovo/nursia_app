// lib/main.dart

import 'package:flutter/material.dart';
import 'package:nursia_app/data/local/daos/calculadora_dao.dart';
import 'package:nursia_app/data/local/daos/escala_dao.dart';
import 'package:nursia_app/data/local/daos/medicamento_dao.dart';
import 'package:nursia_app/database/database_helper.dart';
import 'package:nursia_app/repositories/calculadora_repository.dart';
import 'package:nursia_app/repositories/escala_repository.dart';
import 'package:nursia_app/repositories/medicamento_repository.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await DatabaseHelper.instance.database;
  final medicamentoRepo = MedicamentoRepository(MedicamentoDao(db));
  await medicamentoRepo.cargarSemillaSiHaceFalta();
  final escalaRepo = EscalaRepository(EscalaDao(db));
  await escalaRepo.cargarSemillaSiHaceFalta();
  final calculadoraRepo = CalculadoraRepository(CalculadoraDao(db));
  await calculadoraRepo.cargarSemillaSiHaceFalta();
  await DatabaseHelper.instance.cargarNormasDesdeJSON();
  runApp(
    MultiProvider(
      providers: [
        Provider<MedicamentoRepository>.value(value: medicamentoRepo),
        Provider<EscalaRepository>.value(value: escalaRepo),
        Provider<CalculadoraRepository>.value(value: calculadoraRepo),
      ],
      child: const MyApp(),
    ),
  );
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
