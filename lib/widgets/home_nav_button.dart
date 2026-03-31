import 'package:flutter/material.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeNavButton extends StatelessWidget {
  final String title;
  final int tabIndex;
  final IconData icon;

  const HomeNavButton({
    super.key,
    required this.title,
    required this.tabIndex,
    required this.icon,
  });

  // ESTA CLASE MANEJA LOS 4 BOTONES PRINCIPALES DE NAVEGACIÓN

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        DefaultTabController.of(context).animateTo(tabIndex);
      },
      // Decoración de cada botón
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        overlayColor: AppColors.darkPrimaryColor,
        minimumSize: const Size(150, 150),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      // Estructura del botón: Ícono + Texto
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(icon, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
