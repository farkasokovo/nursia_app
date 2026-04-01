import 'package:flutter/material.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'home_dashboard.dart';
import 'placeholder_screen.dart';
import 'calculadora_screen.dart';
import 'escalas_screen.dart';
import 'farmacologia_screen.dart';

const List<Widget> _tabs = [
  Tab(text: "Escalas"),
  Tab(text: "Farmacología"),
  Tab(icon: PhosphorIcon(PhosphorIconsFill.house, size: 28)),
  Tab(text: "Calculadoras"),
  Tab(text: "Placeholder"),
];

const List<Widget> _tabViews = [
  EscalasScreen(),
  FarmacologiaScreen(),
  HomeDashboard(),
  CalculadoraScreen(),
  PlaceholderScreen(),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: 2,
      child: Scaffold(
        extendBody: true,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            const TabBarView(children: _tabViews),
            Positioned(top: 15, left: 15, right: 15, child: _buildTabBar()),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Nursia',
        style: AppTextStyles.appBarTitle.copyWith(fontSize: 25),
      ),
      backgroundColor: AppColors.darkPrimaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const PhosphorIcon(
          PhosphorIconsBold.list,
          color: AppColors.secondaryColor,
        ),
        onPressed: () {},
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: AppColors.darkPrimaryColor,
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
        indicatorColor: AppColors.secondaryColor,
        labelColor: AppColors.secondaryColor,
        unselectedLabelColor: AppColors.accentLightColor,
        labelStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightSecondaryColor,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 15),
        tabs: _tabs,
      ),
    );
  }
}
