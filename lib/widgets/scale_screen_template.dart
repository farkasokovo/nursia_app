import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScaleScreenTemplate extends StatelessWidget {
  final String heroTag;
  final String title;
  final IconData icon;

  final Widget scaleTab;
  final Widget infoTab;

  const ScaleScreenTemplate({
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
        backgroundColor: AppColors.widgetLightBrown,

        body: Column(
          children: [
            const SizedBox(height: 40),

            Hero(
              tag: heroTag,

              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Icon(icon, size: 40, color: AppColors.darkPrimaryColor),
                  const SizedBox(width: 20),

                  Text(title, style: AppTextStyles.titleBrownText),
                ],
              ),
            ),
            const SizedBox(height: 10),

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
                unselectedLabelStyle: TextStyle(fontSize: 15),
                tabs: [
                  Tab(text: "Escala"),

                  Tab(text: "Ver más"),
                ],
              ),
            ),

            Expanded(child: TabBarView(children: [scaleTab, infoTab])),
          ],
        ),
      ),
    );
  }
}
