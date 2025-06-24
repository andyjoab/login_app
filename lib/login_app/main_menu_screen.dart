import 'package:flutter/material.dart';
import 'package:login_app/navMethods/ephimeralDrawer.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Firestore
import 'package:login_app/modelos/modelo_alumno.dart'; // Import Alumno model
import 'package:login_app/modelos/modelo_inscripcion.dart'; // Import Inscripcion model
import 'package:pdf/pdf.dart'; // For PDF document creation
import 'package:pdf/widgets.dart' as pw; // For PDF widgets
import 'package:path_provider/path_provider.dart'; // For getting directory to save file
import 'package:open_filex/open_filex.dart'; // For opening the file
import 'dart:io'; // For File operations

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String? _userUid;
  Alumno? _currentAlumno;
  Inscripcion? _currentInscripcion;
  bool _isLoading = true; // State to manage loading of data

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Call method to fetch user data on init
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userUid = user.uid;
      try {
        // Fetch Alumno data
        final alumnoDoc = await FirebaseFirestore.instance
            .collection('alumnos')
            .doc(_userUid)
            .get();

        if (alumnoDoc.exists) {
          _currentAlumno =
              Alumno.fromFirestore(alumnoDoc.data()!, alumnoDoc.id);

          // Fetch current Inscripcion based on the Alumno's current group and semester
          if (_currentAlumno?.matricula != null &&
              _currentAlumno?.idGrupoActual != null &&
              _currentAlumno?.idSemestreActual != null) {
            final inscripcionQuery = await FirebaseFirestore.instance
                .collection('inscripciones')
                .where('matricula_alumno', isEqualTo: _currentAlumno!.matricula)
                .where('id_grupo', isEqualTo: _currentAlumno!.idGrupoActual)
                .where('id_semestre',
                    isEqualTo: _currentAlumno!.idSemestreActual)
                .limit(
                    1) // Assuming one current enrollment per student, group, and semester
                .get();

            if (inscripcionQuery.docs.isNotEmpty) {
              _currentInscripcion = Inscripcion.fromFirestore(
                  inscripcionQuery.docs.first.data(),
                  inscripcionQuery.docs.first.id);
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching user data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos del usuario: $e')),
        );
      } finally {
        setState(() {
          _isLoading =
              false; // Set loading to false once data fetching is complete
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        debugPrint("No user logged in.");
      });
    }
  }

  Future<void> _generateAndDownloadSchedulePdf() async {
    if (_currentAlumno == null ||
        _currentInscripcion == null ||
        _currentInscripcion!.materiasInscritas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'No hay información de horario disponible para descargar.')),
      );
      return;
    }

    final pdf = pw.Document();

    // Organize schedule data by day
    Map<String, List<MateriaInscrita>> scheduleByDay = {};
    for (var materia in _currentInscripcion!.materiasInscritas) {
      materia.horarioClase.forEach((day, time) {
        if (!scheduleByDay.containsKey(day)) {
          scheduleByDay[day] = [];
        }
        scheduleByDay[day]!.add(materia);
      });
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Horario de Clases',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                  'Nombre completo: ${_currentAlumno!.nombre} ${_currentAlumno!.apellido}'),
              pw.Text('Matrícula: ${_currentAlumno!.matricula}'),
              pw.Text('Semestre: ${_currentInscripcion!.idSemestre}'),
              pw.Text('Grupo: ${_currentInscripcion!.idGrupo}'),
              pw.SizedBox(height: 20),
              pw.Divider(),
              // Use a Column for each day to ensure proper spacing and order
              ...scheduleByDay.keys.map((day) {
                // Sort classes by time for each day
                scheduleByDay[day]!.sort((a, b) {
                  String timeA = a.horarioClase[day] ?? '';
                  String timeB = b.horarioClase[day] ?? '';
                  // Extract start time for comparison (assuming format "HH:MM-HH:MM")
                  String startA = timeA.split('-')[0];
                  String startB = timeB.split('-')[0];
                  return startA.compareTo(startB);
                });

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 10),
                    pw.Text(
                      _capitalize(day), // Capitalize the day name
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Divider(),
                    ...scheduleByDay[day]!.map((materia) {
                      return pw.Row(
                        children: [
                          pw.Text(
                            '${materia.horarioClase[day]}: ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                                '${materia.nombreAsignatura} (${materia.nombreIngeniero})'),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/horario_clases.pdf');
      await file.writeAsBytes(await pdf.save());
      OpenFilex.open(file.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Horario descargado en: ${file.path}')),
      );
    } catch (e) {
      debugPrint("Error saving or opening PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar el horario: $e')),
      );
    }
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InscribeTEC')),
      drawer: const EphimeralDrawerNavigation(),
      body: _isLoading // Show loading indicator
          ? const Center(child: CircularProgressIndicator())
          : _currentAlumno == null // If no student data found
              ? const Center(
                  child: Text('No se pudo cargar la información del alumno.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenid@ ${_currentAlumno!.nombre}!',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Horario de Clases',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (_currentInscripcion == null ||
                          _currentInscripcion!.materiasInscritas.isEmpty)
                        const Text(
                          'No tienes materias inscritas para este semestre.',
                          style: TextStyle(fontSize: 16),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount:
                                _currentInscripcion!.materiasInscritas.length,
                            itemBuilder: (context, index) {
                              final materia =
                                  _currentInscripcion!.materiasInscritas[index];
                              // Display each subject and its schedule
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        materia.nombreAsignatura,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          'Ingeniero: ${materia.nombreIngeniero}'),
                                      // Display each day and time for the subject
                                      ...materia.horarioClase.entries
                                          .map((entry) {
                                        return Text(
                                            '${_capitalize(entry.key)}: ${entry.value}');
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                      if (_currentInscripcion != null &&
                          _currentInscripcion!.materiasInscritas.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: _generateAndDownloadSchedulePdf,
                          icon: const Icon(Icons.download),
                          label: const Text('Descarga tu horario'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
