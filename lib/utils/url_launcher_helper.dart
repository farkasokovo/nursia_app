// lib/utils/url_launcher_helper.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> abrirUrl(BuildContext context, String urlString) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final uri = Uri.parse(urlString.trim());
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success) {
      messenger.showSnackBar(
        const SnackBar(content: Text("No se pudo abrir la referencia")),
      );
    }
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text("URL inválida en referencias")),
    );
  }
}
