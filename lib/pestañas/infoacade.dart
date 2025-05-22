// lib/pestañas/infoacade.dart
import 'package:flutter/material.dart';

class AcademicInfo extends StatelessWidget {
  const AcademicInfo({super.key});

  void _downloadFile(String fileName) {
    debugPrint('Simulando descarga de: $fileName');
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(
      null!, // Usar Builder o pasar el context de forma segura
    ).showSnackBar(SnackBar(content: Text('Simulando descarga de: $fileName')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Añadimos el AppBar aquí
        title: const Text('Información académica'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          // Botón de retroceso explícito
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.assignment, // Icono de documento/acta
                label: 'Acta de Calificaciones',
                onPressed: () => _downloadFile('acta_calificaciones.pdf'),
              ),
              const SizedBox(height: 20),
              _buildMenuItem(
                context,
                icon: Icons.book, // Icono de libro
                label: 'Historial Académico',
                onPressed: () => _downloadFile('historial_academico.pdf'),
              ),
              const SizedBox(height: 20),
              _buildMenuItem(
                context,
                icon: Icons.grade, // Icono de calificación
                label: 'Calificaciones',
                onPressed: () => _downloadFile('calificaciones.pdf'),
              ),
              const SizedBox(height: 20),
              _buildMenuItem(
                context,
                icon: Icons.pie_chart, // Icono de gráfica de pastel
                label: 'Análisis',
                onPressed: () => _downloadFile('analisis.pdf'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 30),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
