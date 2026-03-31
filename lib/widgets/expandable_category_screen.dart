import 'package:flutter/material.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ExpandableCategoryScreen extends StatelessWidget {
  final String heroTag;
  final String title;
  final IconData icon;
  final Widget child;

  const ExpandableCategoryScreen({
    super.key,
    required this.heroTag,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Hero(
        tag: heroTag,

        child: Material(
          color: AppColors.darkPrimaryColor,

          child: SafeArea(
            child: Column(
              spacing: 8,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: PhosphorIcon(
                        PhosphorIconsBold.caretLeft,
                        color: AppColors.secondaryColor,
                        size: 32,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),

                    const SizedBox(width: 8),

                    PhosphorIcon(
                      icon,
                      size: 28,
                      color: AppColors.secondaryColor,
                    ),

                    const SizedBox(width: 10),

                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                Expanded(
                  child: Container(
                    color: AppColors.widgetLightBrown,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
