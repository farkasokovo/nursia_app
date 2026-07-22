// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nursia_app/data/local/daos/calculadora_dao.dart';
import 'package:nursia_app/data/local/daos/catalogo_pendiente_dao.dart';
import 'package:nursia_app/data/local/daos/escala_dao.dart';
import 'package:nursia_app/data/local/daos/medicamento_dao.dart';
import 'package:nursia_app/data/local/daos/medicamento_turno_dao.dart';
import 'package:nursia_app/data/local/daos/norma_dao.dart';
import 'package:nursia_app/data/local/daos/paciente_turno_dao.dart';
import 'package:nursia_app/data/local/daos/pendiente_turno_dao.dart';
import 'package:nursia_app/database/database_helper.dart';
import 'package:nursia_app/repositories/calculadora_repository.dart';
import 'package:nursia_app/repositories/escala_repository.dart';
import 'package:nursia_app/repositories/medicamento_repository.dart';
import 'package:nursia_app/repositories/medicamento_turno_repository.dart';
import 'package:nursia_app/repositories/norma_repository.dart';
import 'package:nursia_app/repositories/paciente_turno_repository.dart';
import 'package:nursia_app/repositories/pendiente_turno_repository.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'utils/route_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquea la orientación en vertical (portrait) en todos los dispositivos,
  // teléfono o tablet. Se aplica lo antes posible en el arranque para evitar
  // que el usuario alcance a ver un frame en horizontal.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Blindaje del arranque: si abrir la BD o sembrar alguna semilla falla
  // (ej. un JSON mal formado tras una actualización, o una BD corrupta en un
  // dispositivo raro), no dejamos que la app crashee con pantalla negra: la
  // capturamos y mostramos una pantalla de error legible.
  try {
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
    final medicamentoTurnoRepo = MedicamentoTurnoRepository(
      MedicamentoTurnoDao(db),
    );
    runApp(
      MultiProvider(
        providers: [
          Provider<MedicamentoRepository>.value(value: medicamentoRepo),
          Provider<EscalaRepository>.value(value: escalaRepo),
          Provider<CalculadoraRepository>.value(value: calculadoraRepo),
          Provider<NormaRepository>.value(value: normaRepo),
          Provider<PacienteTurnoRepository>.value(value: pacienteTurnoRepo),
          Provider<PendienteTurnoRepository>.value(value: pendienteTurnoRepo),
          Provider<MedicamentoTurnoRepository>.value(
            value: medicamentoTurnoRepo,
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint('Error al iniciar la aplicación: $e');
    debugPrint('$stack');
    runApp(ErrorArranqueApp(detalle: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nurska',
      theme: AppTheme.lightTheme(),
      home: const HomeScreen(),
      navigatorObservers: [appRouteObserver],
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Pantalla mínima que se muestra si el arranque falla, en vez de crashear
/// con pantalla negra. Sin dependencias del tema ni de providers (que quizá
/// no llegaron a inicializarse), para que siempre pueda dibujarse.
class ErrorArranqueApp extends StatelessWidget {
  final String detalle;

  const ErrorArranqueApp({super.key, required this.detalle});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nurska',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 56),
                  const SizedBox(height: 20),
                  const Text(
                    'Ocurrió un problema al iniciar la aplicación.\n'
                    'Intenta reabrirla o reinstalarla.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    detalle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
