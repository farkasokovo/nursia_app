import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
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
    return DefaultTabController(
      length: 2,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: Column(
          children: [
            Hero(
              tag: heroTag,

              child: Material(
                color: AppColors.darkPrimaryColor,

                child: SafeArea(
                  child: Row(
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
                ),
              ),
            ),

            Container(
              width: double.infinity,

              decoration: BoxDecoration(color: AppColors.darkPrimaryColor),
              child: const TabBar(
                tabAlignment: TabAlignment.fill,
                labelPadding: EdgeInsets.symmetric(horizontal: 20),
                dividerColor: Colors.transparent,
                indicatorColor: AppColors.secondaryColor,
                labelColor: AppColors.secondaryColor,
                unselectedLabelColor: AppColors.accentLightColor,
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightSecondaryColor,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: "Escala"),

                  Tab(text: "Ver más"),
                ],
              ),
            ),

            Expanded(
              child: Container(
                color: AppColors.widgetLightBrown,
                child: TabBarView(children: [scaleTab, infoTab]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
