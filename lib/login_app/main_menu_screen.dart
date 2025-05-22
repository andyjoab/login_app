// lib/login_app/main_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:login_app/navMethods/ephimeralDrawer.dart';
// No necesitas importar PageOne, AcademicInfo, etc., directamente aquí si las rutas se manejan en main.dart

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InscribeTEC')),
      drawer: const EphimeralDrawerNavigation(),
      body: const Center(
        child: Text('¡Bienvenid@ a InscribeTEC!'),
      ), // Pantalla de bienvenida principal
    );
  }
}
