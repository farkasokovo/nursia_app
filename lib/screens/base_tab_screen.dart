import 'package:flutter/material.dart';

// ESTO AÑADE TAB BAR A LAS CALCULADORAS

class BaseTabScreen extends StatelessWidget {
  final String title;

  final TabController controller;

  final List<Tab> tabs;

  final List<Widget> views;

  const BaseTabScreen({
    super.key,
    required this.title,
    required this.controller,
    required this.tabs,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),

        bottom: TabBar(controller: controller, tabs: tabs),
      ),

      body: TabBarView(controller: controller, children: views),
    );
  }
}
