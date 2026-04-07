import '../database/database_helper.dart'; // Ajusta la ruta según tu proyecto
import '../models/calculadora_info.dart';

class RepositorioCalculadoras {
  // Ahora es mucho más limpio, ya no necesitamos cargar el JSON aquí
  static Future<CalculadoraInfo> getInfo(String id) async {
    final info = await DatabaseHelper.instance.obtenerInfoCalculadora(id);

    if (info != null) {
      return info;
    } else {
      // Por si algo sale mal, devolvemos un objeto vacío para que no truene la app
      throw Exception("No se encontró la calculadora con id: $id");
    }
  }
}
