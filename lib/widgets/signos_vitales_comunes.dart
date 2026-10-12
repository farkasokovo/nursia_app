// lib/widgets/signos_vitales_comunes.dart
//
// Piezas compartidas por las pantallas de signos vitales pediátricos y del
// adulto: tarjetas, pastillas de resultado, botones y el armazón de la
// pestaña "Información". Viven aquí para que las dos pantallas se vean igual
// y un ajuste de color o de tamaño se haga una sola vez.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/escala_repository.dart';
import '../theme/alert_colors.dart';
import '../theme/app_theme.dart';
import '../theme/theme_colors.dart';
import '../utils/signos_vitales_pediatricos.dart'
    show NivelSigno, ResultadoSigno;
import 'estructura_ver_mas_screen.dart';

/// Gravedad clínica del resultado, en el vocabulario compartido de alertas.
/// Sigue la misma gradación que la calculadora de PAM: verde para lo normal y
/// la escala de rojos conforme sube la gravedad.
///
/// Devuelve null en `noValorable`, que NO es un nivel de alerta: no hay nada
/// que valorar todavía, así que no le toca ningún color de la escala clínica
/// sino el neutro de [colorNivelSigno].
NivelAlerta? _nivelAlerta(NivelSigno nivel) => switch (nivel) {
  NivelSigno.normal => NivelAlerta.verde,
  NivelSigno.bajo => NivelAlerta.sinAlerta,
  NivelSigno.leve => NivelAlerta.rojo1,
  NivelSigno.moderada => NivelAlerta.rojo2,
  NivelSigno.grave => NivelAlerta.rojo3,
  NivelSigno.noValorable => null,
};

/// Color de la pastilla. Es un relleno sólido con texto encima, así que le
/// toca la variante `fill`.
Color colorNivelSigno(BuildContext context, NivelSigno nivel) {
  final alerta = _nivelAlerta(nivel);
  if (alerta != null) return AlertColors.fill(context, alerta);
  return AlertColors.neutro(context);
}

/// Dos campos lado a lado. Se alinean por arriba porque uno puede llevar
/// pastilla y el otro no, y entonces tienen distinto alto.
class RenglonSignos extends StatelessWidget {
  final Widget izquierda;
  final Widget derecha;

  const RenglonSignos({
    super.key,
    required this.izquierda,
    required this.derecha,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: izquierda),
        const SizedBox(width: 12),
        Expanded(child: derecha),
      ],
    );
  }
}

/// Tarjeta de un signo vital.
///
/// Agrupa el campo (o los dos, en la presión) con su pastilla, para que se
/// lea dónde termina un signo y empieza el siguiente. El color es el más
/// claro del tema, de modo que queda una escala de tres tonos: el fondo de
/// la pestaña es el más oscuro, la tarjeta el más claro y el campo, que tiene
/// su propio relleno y su borde, queda en medio.
class TarjetaSigno extends StatelessWidget {
  final Widget child;

  const TarjetaSigno({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: ThemeColors.tarjetaSobreFondo(context),
        borderRadius: BorderRadius.circular(30),
      ),
      child: child,
    );
  }
}

/// Un campo con su interpretación debajo, dentro de su tarjeta. La pastilla
/// aparece donde el usuario ya estaba mirando, en vez de en un bloque al
/// final de la pantalla.
///
/// [debajoDelCampo] va entre el campo y la pastilla: ahí van los selectores
/// que cambian cómo se interpreta ese signo (EPOC y oxígeno en la saturación
/// del adulto).
class CampoSigno extends StatelessWidget {
  final Widget campo;
  final ResultadoSigno? resultado;
  final List<Widget> debajoDelCampo;

  const CampoSigno({
    super.key,
    required this.campo,
    required this.resultado,
    this.debajoDelCampo = const [],
  });

  @override
  Widget build(BuildContext context) {
    return TarjetaSigno(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          campo,
          ...debajoDelCampo,
          if (resultado != null) PastillaSigno(resultado!),
        ],
      ),
    );
  }
}

/// La pastilla de interpretación: compacta, de un renglón cuando el texto
/// alcanza. Conserva el color por gravedad de la calculadora de PAM.
class PastillaSigno extends StatelessWidget {
  final ResultadoSigno resultado;

  const PastillaSigno(this.resultado, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: colorNivelSigno(context, resultado.nivel),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          resultado.etiqueta,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            // Crema en los dos temas. En claro `onPrimary` YA es crema y se
            // conserva tal cual; en oscuro ese mismo token es casi negro
            // (#241B14) y sobre el relleno oscuro caería a 1.92:1.
            color: theme.brightness == Brightness.dark
                ? AppColorsDark.ink
                : colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// "Limpiar" e "Interpretar". El principal va a la derecha, donde cae el
/// pulgar.
class BotonesSignos extends StatelessWidget {
  final VoidCallback onLimpiar;
  final VoidCallback onInterpretar;

  const BotonesSignos({
    super.key,
    required this.onLimpiar,
    required this.onInterpretar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: onLimpiar,
            style: OutlinedButton.styleFrom(
              overlayColor: colorScheme.onSurface,
              minimumSize: const Size(double.infinity, 60),
              side: BorderSide(color: colorScheme.onSurface, width: 2),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.defaultRadius,
              ),
            ),
            child: Text(
              "Limpiar",
              style: textTheme.titleSmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: onInterpretar,
            style: ElevatedButton.styleFrom(
              overlayColor: colorScheme.tertiaryContainer,
              minimumSize: const Size(double.infinity, 60),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.defaultRadius,
              ),
            ),
            child: Text(
              "Interpretar",
              style: textTheme.titleSmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Título de una tabla de referencia y la tabla debajo.
class SeccionTablaSigno extends StatelessWidget {
  final String titulo;
  final Widget tabla;

  const SeccionTablaSigno({
    super.key,
    required this.titulo,
    required this.tabla,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          tabla,
        ],
      ),
    );
  }
}

/// Pestaña "Información": las tablas de referencia arriba y el texto de la
/// escala debajo. El texto dice "los cortes exactos están en las tablas de
/// arriba", así que el orden importa.
class InformacionSignosVitales extends StatelessWidget {
  /// Id de la entrada en `scales_data.json`.
  final String idEscala;
  final List<Widget> tablas;

  const InformacionSignosVitales({
    super.key,
    required this.idEscala,
    required this.tablas,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...tablas,
              FutureBuilder(
                future: context.read<EscalaRepository>().obtenerPorId(idEscala),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || snapshot.data == null) {
                    return Center(
                      child: Text(
                        "No se pudo cargar la información de esta escala.",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    );
                  }
                  return EstructuraVerMasScreen(info: snapshot.data!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
