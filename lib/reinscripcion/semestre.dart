import 'package:flutter/material.dart';
import 'package:login_app/reinscripcion/grupo.dart'; // Para navegar a la selección de grupo
import 'package:login_app/modelos/modelo_semestre.dart'; // Importa tu modelo Semestre
import 'package:login_app/servicio/firestore_service.dart'; // Importa tu FirestoreService

class Seleccionsemestre extends StatefulWidget {
  const Seleccionsemestre({super.key});

  @override
  State<Seleccionsemestre> createState() => _SeleccionsemestreState();
}

class _SeleccionsemestreState extends State<Seleccionsemestre> {
  // Instancia servicio Firestore
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '¿A cual semestre ingresas?',
            style:
                Theme.of(context).textTheme.headlineSmall, // Ajusta el estilo
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Expanded(
            // Usamos StreamBuilder para escuchar cambios en tiempo real
            child: StreamBuilder<List<Semestre>>(
              stream: _firestoreService
                  .getSemestresActivos(), // O getSemestres() si no filtras
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print("Error al cargar semestres: ${snapshot.error}");
                  return Center(
                      child:
                          Text('Error al cargar semestres: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No hay semestres activos disponibles.'));
                }

                final semestres = snapshot.data!;
                return ListView(
                  children: semestres.map((semestre) {
                    // Define el color del botón basado en el nombre del semestre
                    Color buttonColor;
                    switch (semestre.nombreSemestre) {
                      case '1° Semestre':
                        buttonColor = const Color(0XFF95FAB9);
                        break;
                      case '2° Semestre':
                        buttonColor = const Color(0xFFFFB5E8);
                        break;
                      case '3° Semestre':
                        buttonColor = const Color(0XFFAFCBFF);
                        break;
                      case '4° Semestre':
                        buttonColor = const Color(0xFFA79AFF);
                        break;
                      case '5° Semestre':
                        buttonColor = const Color(0xFFF6A6FF);
                        break;
                      case '6° Semestre':
                        buttonColor = const Color(0XFFC4FAF8);
                        break;
                      case '7° Semestre':
                        buttonColor = const Color(0xFFC3F8FF);
                        break;
                      case '8° Semestre':
                        buttonColor = const Color(0xFFFF85D5);
                        break;
                      case '9° Semestre':
                        buttonColor = const Color(0xFFFDFD96);
                        break;
                      default:
                        buttonColor = Colors.grey;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildSemesterButton(
                          context,
                          semestre.nombreSemestre,
                          semestre.idSemestre,
                          buttonColor), // Pasa el ID
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterButton(BuildContext context, String nombreSemestre,
      String idSemestre, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        minimumSize: const Size.fromHeight(50),
      ),
      onPressed: () {
        // Navega a la pantalla de selección de grupo, pasando el ID y nombre del semestre
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Selecciongrupo(
                semesterId: idSemestre, // Pasa el ID del semestre
                semesterName: nombreSemestre), // Pasa el nombre del semestre
          ),
        );
      },
      child: Text(
        nombreSemestre,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
