// ignore: file_names
import 'package:flutter/material.dart';

class EphimeralDrawerNavigation extends StatelessWidget {
  const EphimeralDrawerNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Color.fromARGB(255, 85, 112, 233)),
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
              // Cierra el drawer y navega a la ruta '/one'
              Navigator.pop(context); // Cierra el drawer
              Navigator.pushNamed(context, '/one');
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text(
              'Información académica',
              style: TextStyle(color: Color.fromARGB(255, 18, 103, 230)),
            ),
            onTap: () {
              // Cierra el drawer y navega a la ruta '/two'
              Navigator.pop(context); // Cierra el drawer
              Navigator.pushNamed(context, '/two');
            },
          ),
          ListTile(
            leading: const Icon(Icons.abc_sharp),
            title: const Text(
              'Reinscripción',
              style: TextStyle(color: Color.fromARGB(255, 133, 130, 126)),
            ),
            onTap: () {
              // Cierra el drawer y navega a la ruta '/three'
              Navigator.pop(context); // Cierra el drawer
              Navigator.pushNamed(context, '/three');
            },
          ),
          ListTile(
            leading: const Icon(Icons.source_sharp),
            title: const Text(
              'Servicio social/Residencias',
              style: TextStyle(color: Color.fromARGB(255, 255, 12, 162)),
            ),
            onTap: () {
              // Cierra el drawer y navega a la nueva pantalla de Servicio/Residencias
              Navigator.pop(context); // Cierra el drawer
              Navigator.pushNamed(context, '/four'); // <--- Cambia esta ruta
            },
          ),
          const Divider(), // Un separador para el botón de cerrar sesión
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ), // Icono de flecha hacia afuera y color rojo
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: Colors.red, // Color rojo para el texto
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              // Cierra el drawer
              Navigator.pop(context);
              // Navega a la pantalla de login y elimina todas las rutas anteriores
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/', // La ruta de tu pantalla de login (normalmente '/')
                (Route<dynamic> route) =>
                    false, // Elimina todas las rutas del stack
              );
            },
          ),
        ],
      ),
    );
  }
}
