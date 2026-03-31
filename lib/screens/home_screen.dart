import 'package:flutter/material.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'home_dashboard.dart';
import 'placeholder_screen.dart';
import 'calculadora_screen.dart';
import 'escalas_screen.dart';
import 'farmacologia_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: 2,
      child: Scaffold(
        extendBody:
            true, // Importante: permite que el body se vea detrás de la barra
        appBar: AppBar(
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
        ),
        body: Stack(
          children: [
            // 1. El contenido va al fondo
            const TabBarView(
              children: [
                EscalasScreen(),
                FarmacologiaScreen(),
                HomeDashboard(),
                CalculadoraScreen(),
                PlaceholderScreen(),
              ],
            ),

            // 2. La TabBar Flotante
            Positioned(
              top: 15, // Distancia del borde inferior
              left: 15,
              right: 15,
              child: Container(
                height: 55,
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
                  isScrollable: true, // Mantiene el scroll lateral
                  tabAlignment: TabAlignment
                      .center, // Alinea al inicio para que el scroll se sienta natural
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ), // <--- DALE AIRE AL TEXTO AQUÍ
                  dividerColor: Colors.transparent,
                  indicatorColor: AppColors.secondaryColor,
                  labelColor: AppColors.secondaryColor,
                  unselectedLabelColor: AppColors.accentLightColor,
                  tabs: const [
                    Tab(text: "Escalas"),
                    Tab(text: "Farmacología"),
                    Tab(icon: PhosphorIcon(PhosphorIconsFill.house, size: 28)),
                    Tab(text: "Calculadoras"),
                    Tab(text: "Placeholder"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
