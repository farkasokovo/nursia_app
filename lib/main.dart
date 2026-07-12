// lib/main.dart

import 'package:flutter/material.dart';
import 'package:nursia_app/data/local/daos/calculadora_dao.dart';
import 'package:nursia_app/data/local/daos/catalogo_pendiente_dao.dart';
import 'package:nursia_app/data/local/daos/escala_dao.dart';
import 'package:nursia_app/data/local/daos/medicamento_dao.dart';
import 'package:nursia_app/data/local/daos/norma_dao.dart';
import 'package:nursia_app/data/local/daos/paciente_turno_dao.dart';
import 'package:nursia_app/data/local/daos/pendiente_turno_dao.dart';
import 'package:nursia_app/database/database_helper.dart';
import 'package:nursia_app/repositories/calculadora_repository.dart';
import 'package:nursia_app/repositories/escala_repository.dart';
import 'package:nursia_app/repositories/medicamento_repository.dart';
import 'package:nursia_app/repositories/norma_repository.dart';
import 'package:nursia_app/repositories/paciente_turno_repository.dart';
import 'package:nursia_app/repositories/pendiente_turno_repository.dart';
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
  final normaRepo = NormaRepository(NormaDao(db));
  await normaRepo.cargarSemillaSiHaceFalta();
  final pacienteTurnoRepo = PacienteTurnoRepository(PacienteTurnoDao(db));
  final pendienteTurnoRepo = PendienteTurnoRepository(
    CatalogoPendienteDao(db),
    PendienteTurnoDao(db),
  );
  await pendienteTurnoRepo.cargarSemillaSiHaceFalta();
  runApp(
    MultiProvider(
      providers: [
        Provider<MedicamentoRepository>.value(value: medicamentoRepo),
        Provider<EscalaRepository>.value(value: escalaRepo),
        Provider<CalculadoraRepository>.value(value: calculadoraRepo),
        Provider<NormaRepository>.value(value: normaRepo),
        Provider<PacienteTurnoRepository>.value(value: pacienteTurnoRepo),
        Provider<PendienteTurnoRepository>.value(value: pendienteTurnoRepo),
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
