import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'home_dashboard.dart';
import 'normativa_screen.dart';
import 'calculadora_screen.dart';
import 'escalas_screen.dart';
import 'farmacologia_screen.dart';

const List<Widget> _tabs = [
  Tab(text: "Escalas"),
  Tab(text: "Farmacología"),
  Tab(icon: PhosphorIcon(PhosphorIconsFill.house, size: 28)),
  Tab(text: "Calculadoras"),
  Tab(text: "Normativas"),
];

const List<Widget> _tabViews = [
  EscalasScreen(),
  FarmacologiaScreen(),
  HomeDashboard(),
  CalculadoraScreen(),
  NormativaScreen(),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DefaultTabController(
      length: 5,
      initialIndex: 2,
      child: Scaffold(
        backgroundColor: colorScheme.secondary,
        extendBody: true,
        appBar: _buildAppBar(theme, colorScheme, textTheme),
        body: Stack(
          children: [
            const TabBarView(children: _tabViews),
            Positioned(
              top: 15,
              left: 15,
              right: 15,
              child: _buildTabBar(theme, colorScheme, textTheme),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(
    ThemeData theme,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return AppBar(
      title: Text(
        'Nursia',
        style: textTheme.titleLarge?.copyWith(
          fontSize: 25,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      backgroundColor: colorScheme.primaryContainer,
      elevation: 0,
      leading: IconButton(
        icon: PhosphorIcon(
          PhosphorIconsBold.list,
          color: colorScheme.onPrimaryContainer,
        ),
        onPressed: () {},
      ),
    );
  }

  Widget _buildTabBar(
    ThemeData theme,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.center,
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
        tabs: _tabs,
      ),
    );
  }
}
