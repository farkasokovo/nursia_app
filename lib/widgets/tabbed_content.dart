// lib/widgets/tabbed_content.dart
import 'package:flutter/material.dart';

class TabbedContent extends StatefulWidget {
  final List<Tab> tabs;
  final List<Widget> tabViews;
  final TabController? controller; // opcional, si quieres control externo

  const TabbedContent({
    super.key,
    required this.tabs,
    required this.tabViews,
    this.controller,
  });

  @override
  State<TabbedContent> createState() => _TabbedContentState();
}

class _TabbedContentState extends State<TabbedContent>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        // TabBar con el estilo consistente
        Container(
          color: colorScheme.primaryContainer,
          child: TabBar(
            controller: _controller,
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
            tabs: widget.tabs,
          ),
        ),
        // Contenido de las pestañas
        Expanded(
          child: TabBarView(controller: _controller, children: widget.tabViews),
        ),
      ],
    );
  }
}
