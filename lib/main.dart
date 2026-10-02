import 'package:flutter/material.dart';
import 'package:sat_it8700/app/ui/core/app_menu_bar.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: AppMenuBar(child: Center(child: Text("Teste"))),
      ),
    );
  }
}
