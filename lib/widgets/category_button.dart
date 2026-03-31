import 'package:flutter/material.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CategoryButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final String heroTag;
  final Color color;

  const CategoryButton({
    super.key,
    required this.title,
    required this.icon,
    required this.heroTag,
    this.onTap,
    this.color = AppColors.widgetLightBrown,
  });
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(icon, size: 40, color: AppColors.darkPrimaryColor),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleBrownText.copyWith(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
