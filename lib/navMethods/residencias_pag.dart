import 'package:flutter/material.dart';

class ResidenciasPage extends StatelessWidget {
  const ResidenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Residencias Profesionales'),
        backgroundColor: const Color.fromARGB(255, 179, 247, 238),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center,
              size: 80,
              color: Color.fromARGB(255, 179, 247, 238),
            ),
            SizedBox(height: 20),
            Text(
              'Contenido de Residencias Profesionales',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Aquí se mostrará toda la información y opciones relacionadas con las Residencias Profesionales.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
