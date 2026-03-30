import 'package:flutter/material.dart';
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
              Expanded(child: HomeNavButton(title: "Escalas", tabIndex: 0)),

              SizedBox(width: 16),

              Expanded(child: HomeNavButton(title: "Placeholder", tabIndex: 4)),
            ],
          ),

          SizedBox(height: 16),

          Row(
            children: const [
              Expanded(child: HomeNavButton(title: "Fármacos", tabIndex: 1)),

              SizedBox(width: 16),

              Expanded(
                child: HomeNavButton(title: "Calculadoras", tabIndex: 3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
