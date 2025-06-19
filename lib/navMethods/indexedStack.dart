import 'package:flutter/material.dart';
import 'package:login_app/components/pages.dart';
import 'package:login_app/pestañas/infoacade.dart' as infoacade;
import 'package:login_app/reinscripcion.dart' as reinscripcion;

class IndexedStackNavigation extends StatefulWidget {
  const IndexedStackNavigation({super.key});

  @override
  State<IndexedStackNavigation> createState() => _IndexedStackNavigationState();
}

class _IndexedStackNavigationState extends State<IndexedStackNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const <Widget>[
          PageOne(),
          infoacade.AcademicInfo(),
          reinscripcion.PageThree(),
          PageFour(),
        ],
      ),
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
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
