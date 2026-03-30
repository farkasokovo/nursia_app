import 'package:flutter/material.dart';

class HomeNavButton extends StatelessWidget {
  final String title;
  final int tabIndex;

  const HomeNavButton({super.key, required this.title, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        DefaultTabController.of(context).animateTo(tabIndex);
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(150, 150),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            20,
          ), // 👈 AQUÍ CONTROLAS EL REDONDEO
        ),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
