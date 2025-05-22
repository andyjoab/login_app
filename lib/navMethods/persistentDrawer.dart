import 'package:flutter/material.dart';
import 'package:login_app/components/pages.dart';
import 'package:login_app/pestañas/infoacade.dart'
    as infoacade; // Asegúrate de que esta importación sea correcta

class PersistentDrawer extends StatefulWidget {
  const PersistentDrawer({super.key});

  @override
  State<PersistentDrawer> createState() => _PersistentDrawerState();
}

class _PersistentDrawerState extends State<PersistentDrawer> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const PageOne(),
    const infoacade.AcademicInfo(),
    const PageThree(),
    const PageFour(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InscribeTEC')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 93, 96, 252),
              ),
              child: Text(
                'InscribeTEC',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(
                'Información personal',
                style: TextStyle(color: Color.fromARGB(255, 124, 212, 124)),
              ),
              onTap: () {
                _selectPage(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text(
                'Información académica',
                style: TextStyle(color: Color.fromARGB(255, 18, 103, 230)),
              ),
              onTap: () {
                _selectPage(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.abc_sharp),
              title: const Text(
                'Reinscripción',
                style: TextStyle(color: Color.fromARGB(255, 133, 130, 126)),
              ),
              onTap: () {
                _selectPage(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.source_sharp),
              title: const Text(
                'Servicio social/Residencias',
                style: TextStyle(color: Color.fromARGB(255, 255, 12, 162)),
              ),
              onTap: () {
                _selectPage(3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
