import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MoldeEscalasScreen extends StatelessWidget {
  final String heroTag;
  final String title;
  final IconData icon;
  final Widget scaleTab;
  final Widget infoTab;

  const MoldeEscalasScreen({
    super.key,
    required this.heroTag,
    required this.title,
    required this.icon,
    required this.scaleTab,
    required this.infoTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Hero(
              tag: heroTag,
              child: Material(
                color: colorScheme.primaryContainer,
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: PhosphorIcon(
                          PhosphorIconsBold.caretLeft,
                          color: colorScheme.onPrimaryContainer,
                          size: 32,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      PhosphorIcon(
                        icon,
                        size: 28,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: colorScheme.primaryContainer),
              child: TabBar(
                tabAlignment: TabAlignment.fill,
                labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                dividerColor: Colors.transparent,
                indicatorColor: colorScheme.onPrimaryContainer,
                labelColor: colorScheme.onPrimaryContainer,
                unselectedLabelColor: colorScheme.tertiaryContainer,
                labelStyle: textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: textTheme.titleSmall?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: "Escala"),
                  Tab(text: "Ver más"),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: colorScheme.secondaryContainer,
                child: TabBarView(children: [scaleTab, infoTab]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
