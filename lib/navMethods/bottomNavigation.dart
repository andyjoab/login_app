// ignore: file_names
import 'package:flutter/material.dart';
import '../components/pages.dart'
    as pages; // Mantén esta importación si aún necesitas PageOne, PageThree, PageFour
import 'package:login_app/pestañas/infoacade.dart'
    as infoacade; // <--- Añade esta importación
// Asegúrate de que la ruta sea correcta según la ubicación de tu archivo academic_info_screen.dart.
// Por ejemplo, si está en el mismo nivel que bottomNavigation.dart, podría ser 'academic_info_screen.dart'
// o si está en una carpeta 'screens', podría ser '../screens/academic_info_screen.dart'

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const pages.PageOne(), // Índice 0: Información personal
    const infoacade.AcademicInfo(), // Índice 1: Información académica - ¡Aquí está el cambio!
    const pages.PageThree(), // Índice 2: Reinscripción
    const pages.PageFour(), // Índice 3: Servicio social/Residencias
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barra de navegación')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Información personal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Información académica',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.abc_sharp),
            label: 'Reinscripción',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.source_sharp),
            label: 'Servicio social/Residencias',
          ),
        ],
        unselectedItemColor:
            Colors
                .grey, // Opcional: Define un color para los iconos no seleccionados
        selectedItemColor:
            Colors.blue, // Opcional: Define un color para el icono seleccionado
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
