import 'package:flutter/widgets.dart';

/// Observador de navegación compartido de toda la app.
///
/// Se registra en `MaterialApp(navigatorObservers: [appRouteObserver])` y
/// permite que widgets `RouteAware` (como [CategoryButton]) se enteren cuando
/// se regresa a su pantalla tras cerrar una ficha. Lo usamos para recrear el
/// `Hero` del botón y evitar que quede invisible si el vuelo se interrumpió por
/// una navegación muy rápida.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
