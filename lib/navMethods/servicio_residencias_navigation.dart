import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // Asegúrate de tener esta dependencia en tu pubspec.yaml
import 'package:login_app/navMethods/servicio_social_pag.dart';
import 'package:login_app/navMethods/residencias_pag.dart';

class ServicioResidenciasNavigation extends StatefulWidget {
  const ServicioResidenciasNavigation({super.key});

  @override
  State<ServicioResidenciasNavigation> createState() =>
      _ServicioResidenciasNavigationState();
}

class _ServicioResidenciasNavigationState
    extends State<ServicioResidenciasNavigation> {
  int _selectedIndex = 0; // 0 para Servicio Social, 1 para Residencias

  final List<Widget> _pages = [
    const ServicioSocialPage(),
    const ResidenciasPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.people_alt, size: 30, color: Colors.white),
      const Icon(Icons.business_center, size: 30, color: Colors.white),
    ];

    return Scaffold(
      extendBody:
          true, // Esto es importante para que la barra curvada se vea bien
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor:
            Colors
                .transparent, // Fondo transparente para que se vea el color del Scaffold
        color: const Color.fromARGB(
          255,
          246,
          255,
          116,
        ), // Color de la barra curvada
        buttonBackgroundColor: const Color.fromARGB(
          255,
          246,
          255,
          116,
        ), // Color del botón central (si lo hubiera)
        height: 60,
        index: _selectedIndex,
        items: items,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
