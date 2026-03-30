import 'package:flutter/material.dart';

class NeurologicasScreen extends StatelessWidget {
  const NeurologicasScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Escalas Neurológicas")),
      body: Center(
        child: Hero(
          tag: "neurologicas",
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
