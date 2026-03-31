import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/home_nav_button.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: const [
              Expanded(
                child: HomeNavButton(
                  title: "Escalas",
                  tabIndex: 0,
                  icon: PhosphorIconsRegular.clipboardText,
                ),
              ),

              SizedBox(width: 16),

              Expanded(
                child: HomeNavButton(
                  title: "Placeholder",
                  tabIndex: 4,
                  icon: PhosphorIconsRegular.dotsThreeCircle,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          Row(
            children: const [
              Expanded(
                child: HomeNavButton(
                  title: "Fármacos",
                  tabIndex: 1,
                  icon: PhosphorIconsRegular.pill,
                ),
              ),

              SizedBox(width: 16),

              Expanded(
                child: HomeNavButton(
                  title: "Calculadoras",
                  tabIndex: 3,
                  icon: PhosphorIconsRegular.calculator,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
