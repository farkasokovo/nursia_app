import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ElevatedButton(
      onPressed: () {
        DefaultTabController.of(context).animateTo(tabIndex);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        overlayColor: colorScheme.primaryContainer,
        minimumSize: const Size(150, 150),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(icon, size: 40, color: colorScheme.onPrimary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
