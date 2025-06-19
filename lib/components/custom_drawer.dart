import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 144, 162, 245),
            ),
            child: SizedBox(
              height: 100,
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/5/5f/Logo-TecNM-2017.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Información personal'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/one');
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Información académica'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/two');
            },
          ),
          ListTile(
            leading: const Icon(Icons.abc_sharp),
            title: const Text('Reinscripción'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/three');
            },
          ),
          ListTile(
            leading: const Icon(Icons.source_sharp),
            title: const Text('Servicio social/Residencias'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/four');
            },
          ),
        ],
      ),
    );
  }
}
