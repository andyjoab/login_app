import 'package:flutter/material.dart';

class ServicioSocialPage extends StatelessWidget {
  const ServicioSocialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicio Social'),
        backgroundColor: const Color.fromARGB(255, 255, 185, 234),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_alt,
              size: 80,
              color: Color.fromARGB(255, 255, 185, 234),
            ),
            SizedBox(height: 20),
            Text(
              'Contenido de Servicio Social',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Aquí se mostrará toda la información y opciones relacionadas con el Servicio Social.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
