// lib/screens/infoacade.dart
import 'package:flutter/material.dart';
import 'package:login_app/pestañas/analisis.dart'; // Importa la pantalla de análisis

class AcademicInfo extends StatelessWidget {
  const AcademicInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Información académica'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: Colors.black, // Ensure consistent text color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      // The body now directly displays the GradesAnalysisScreen content
      body: const GradesAnalysisScreen(),
    );
  }
}