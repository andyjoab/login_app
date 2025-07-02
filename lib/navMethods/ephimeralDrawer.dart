// ignore: file_names
import 'package:flutter/material.dart';

class EphimeralDrawerNavigation extends StatelessWidget {
  const EphimeralDrawerNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Fondo blanco
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 150, // Keep a fixed height or adjust as needed
            decoration: const BoxDecoration( // Made const as no dynamic parts
              image: DecorationImage(
                image: AssetImage('assets/Recurso 35.png'),
                fit: BoxFit.contain, // Changed from .cover to .contain
                alignment: Alignment.center, // Center the image within the space
              ),
            ),
            child: const DrawerHeader( // DrawerHeader content can be null if only used for background
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: null, // No content needed directly inside DrawerHeader for this setup
            ),
          ), // Encabezado personalizado
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
              color: Color.fromARGB(255, 116, 112, 112),
            ), // Icono de flecha hacia afuera y color rojo
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: Color.fromARGB(
                    255, 134, 131, 131), // Color rojo para el texto
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