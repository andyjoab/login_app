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
import 'package:flutter/services.dart';

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

  /// Fetches user data (Alumno and current Inscripcion) from Firebase Firestore.
  /// Sets `_currentAlumno` and `_currentInscripcion` states.
  /// Manages `_isLoading` state to show a loading indicator.
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userUid = user.uid;
      try {
        // Fetch Alumno data for the current user
        final alumnoDoc = await FirebaseFirestore.instance
            .collection('alumnos')
            .doc(_userUid)
            .get();

        if (alumnoDoc.exists) {
          _currentAlumno =
              Alumno.fromFirestore(alumnoDoc.data()!, alumnoDoc.id);

          // If Alumno data is available, fetch the current Inscripcion
          // based on the student's current group and semester.
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
            } else {
              debugPrint(
                  "No current enrollment found for student's group and semester.");
              _currentInscripcion = null; // Ensure it's null if not found
            }
          } else {
            debugPrint("Alumno matricula, group ID or semester ID is null.");
            _currentInscripcion =
                null; // Ensure it's null if student data is incomplete
          }
        } else {
          debugPrint("Alumno document does not exist for UID: $_userUid");
          _currentAlumno =
              null; // Ensure it's null if student document is missing
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

  /// Generates a PDF document containing the student's class schedule
  /// and allows the user to download and open it.
  Future<void> _generateAndDownloadSchedulePdf() async {
    // Check if necessary data is available before proceeding
    if (_currentAlumno == null ||
        _currentInscripcion == null ||
        _currentInscripcion!.materiasInscritas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay horario disponible.')),
      );
      return;
    }

    final pdf = pw.Document();

    // Load necessary assets (logos) for the PDF header
    final ByteData logoTecData =
        await rootBundle.load('assets/Logo-TecNM-2017.png');
    final ByteData logoTesTData = await rootBundle.load('assets/TesT.png');
    final ByteData logoIscData = await rootBundle.load('assets/Isc.png');

    final pw.MemoryImage logoTec =
        pw.MemoryImage(logoTecData.buffer.asUint8List());
    final pw.MemoryImage logoTesT =
        pw.MemoryImage(logoTesTData.buffer.asUint8List());
    final pw.MemoryImage logoIsc =
        pw.MemoryImage(logoIscData.buffer.asUint8List());

    // Organize schedule data by day and time for table generation
    // Key: Day of the week (e.g., 'Lunes')
    // Value: List of maps, each containing details for a class on that day
    Map<String, List<Map<String, dynamic>>> scheduleByDayAndTime = {
      'Lunes': [],
      'Martes': [],
      'Miércoles': [],
      'Jueves': [],
      'Viernes': [],
    };

    // Populate the schedule map from enrolled subjects
    for (var materia in _currentInscripcion!.materiasInscritas) {
      // Access the specific fields within materia.horarioClase directly
      String? diasString = materia.horarioClase['dia'] as String?;
      String? horaInicio = materia.horarioClase['hora_inicio'] as String?;
      String? horaFin = materia.horarioClase['hora_fin'] as String?;

      if (diasString != null && horaInicio != null && horaFin != null) {
        // Split the 'dia' string into individual days (e.g., "Martes, Jueves" -> ["Martes", "Jueves"])
        List<String> dias = diasString.split(',').map((d) => d.trim()).toList();
        String horaCompleta = '${horaInicio.trim()}-${horaFin.trim()}';

        for (String day in dias) {
          String capitalizedDay = _capitalize(day);
          if (scheduleByDayAndTime.containsKey(capitalizedDay)) {
            scheduleByDayAndTime[capitalizedDay]!.add({
              'nombreAsignatura': materia.nombreAsignatura,
              'nombreIngeniero': materia.nombreIngeniero,
              'horaInicio': horaInicio.trim(),
              'horaFin': horaFin.trim(),
              'horaCompleta': horaCompleta,
            });
          }
        }
      } else {
        debugPrint(
            "Warning: Missing 'dia', 'hora_inicio', or 'hora_fin' in horarioClase for ${materia.nombreAsignatura}");
      }
    }

    // Sort classes within each day by their start time
    scheduleByDayAndTime.forEach((day, classes) {
      classes.sort((a, b) {
        // Handle potential nulls or malformed strings defensively
        final timeA = (a['horaInicio'] as String? ?? '00:00').split(':');
        final timeB = (b['horaInicio'] as String? ?? '00:00').split(':');

        final int hourA = int.tryParse(timeA[0]) ?? 0;
        final int minuteA =
            int.tryParse(timeA.length > 1 ? timeA[1] : '0') ?? 0;
        final int hourB = int.tryParse(timeB[0]) ?? 0;
        final int minuteB =
            int.tryParse(timeB.length > 1 ? timeB[1] : '0') ?? 0;

        if (hourA != hourB) {
          return hourA.compareTo(hourB);
        }
        return minuteA.compareTo(minuteB);
      });
    });

    // Determine all unique time slots to create table rows dynamically
    Set<String> allTimeSlots = {};
    for (var dayClasses in scheduleByDayAndTime.values) {
      for (var classInfo in dayClasses) {
        allTimeSlots.add(classInfo['horaCompleta']!);
      }
    }
    List<String> sortedTimeSlots = allTimeSlots.toList();
    // Sort the unique time slots chronologically
    sortedTimeSlots.sort((a, b) {
      // Handle potential nulls or malformed strings defensively
      final timeA = (a.split('-')[0] as String? ?? '00:00').split(':');
      final timeB = (b.split('-')[0] as String? ?? '00:00').split(':');

      final int hourA = int.tryParse(timeA[0]) ?? 0;
      final int minuteA = int.tryParse(timeA.length > 1 ? timeA[1] : '0') ?? 0;
      final int hourB = int.tryParse(timeB[0]) ?? 0;
      final int minuteB = int.tryParse(timeB.length > 1 ? timeB[1] : '0') ?? 0;

      if (hourA != hourB) {
        return hourA.compareTo(hourB);
      }
      return minuteA.compareTo(minuteB);
    });

    // Debugging: Print the organized schedule data and time slots
    debugPrint("Schedule by Day and Time (final): $scheduleByDayAndTime");
    debugPrint("Sorted Time Slots (final): $sortedTimeSlots");

    // Build the table rows with complex pw.Widget content for each cell
    List<List<pw.Widget>> tableCells = [];

    // Add table headers as the first row
    tableCells.add([
      pw.Container(
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.all(5),
        decoration: const pw.BoxDecoration(color: PdfColors.blue700),
        child: pw.Text('Horas',
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.white)),
      ),
      for (var day in ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'])
        pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.all(5),
          decoration: const pw.BoxDecoration(color: PdfColors.blue700),
          child: pw.Text(day,
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                  color: PdfColors.white)),
        ),
    ]);

    // Fill table rows with actual schedule data based on time slots and days
    for (String timeSlot in sortedTimeSlots) {
      List<pw.Widget> row = [
        pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.all(5),
          decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5)),
          child: pw.Text(timeSlot,
              style: const pw.TextStyle(fontSize: 8)), // Hour column
        ),
      ];
      for (var day in ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes']) {
        // Filter classes for the current day and time slot
        // Ensure that scheduleByDayAndTime[day] is not null and is a list
        final classesAtThisTime = (scheduleByDayAndTime[day] ?? [])
            .where((c) => c['horaCompleta'] == timeSlot)
            .toList();

        if (classesAtThisTime.isNotEmpty) {
          row.add(
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(3),
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5)),
              child: pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.center, // Center content
                children: classesAtThisTime.map((c) {
                  return pw.Column(
                    children: [
                      pw.Text(
                          c['nombreAsignatura']!
                              as String, // Explicit cast to String
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 8),
                          textAlign: pw.TextAlign.center),
                      pw.Text(
                          c['nombreIngeniero']!
                              as String, // Explicit cast to String
                          style: const pw.TextStyle(fontSize: 7),
                          textAlign: pw.TextAlign.center),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        } else {
          // Empty cell if no class in that time slot for that day
          row.add(
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(3),
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5)),
              child: pw.Text('', style: const pw.TextStyle(fontSize: 8)),
            ),
          );
        }
      }
      tableCells.add(row);
    }

    // Add page to the PDF document
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header section with logos
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logoTec,
                      width: 100), // Ajusta el tamaño según sea necesario
                  pw.Image(logoTesT,
                      width: 120), // Ajusta el tamaño según sea necesario
                  pw.Image(logoIsc,
                      width: 100), // Ajusta el tamaño según sea necesario
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'Horario de clases',
                  style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.normal,
                      color: PdfColors.blue700),
                ),
              ),
              pw.SizedBox(height: 20),
              // Student information section
              pw.Text('Nombre completo: ${_currentAlumno!.nombre}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Matrícula: ${_currentAlumno!.matricula}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Semestre: ${_currentInscripcion!.idSemestre}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Grupo: ${_currentInscripcion!.idGrupo}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 20),
              // Schedule table
              pw.Table(
                border:
                    pw.TableBorder.all(color: PdfColors.grey700, width: 0.8),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.5), // Horas
                  1: const pw.FlexColumnWidth(2), // Lunes
                  2: const pw.FlexColumnWidth(2), // Martes
                  3: const pw.FlexColumnWidth(2), // Miércoles
                  4: const pw.FlexColumnWidth(2), // Jueves
                  5: const pw.FlexColumnWidth(2), // Viernes
                },
                // Use the tableCells list to construct the table rows
                children: tableCells
                    .map((row) => pw.TableRow(children: row))
                    .toList(),
              ),
            ],
          );
        },
      ),
    );

    // Save and open the generated PDF file
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/horario_clases_${_currentAlumno!.matricula}.pdf'); // Nombre de archivo más específico
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

  /// Capitalizes the first letter of a given string.
  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: Text('¡Bienvenido(a) ${_currentAlumno?.nombre ?? ''}!')),
      drawer: const EphimeralDrawerNavigation(),
      body: _isLoading // Show loading indicator while data is being fetched
          ? const Center(child: CircularProgressIndicator())
          : _currentAlumno == null // If no student data found after loading
              ? const Center(
                  child: Text('No se pudo cargar la información del alumno.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add the logo at the top
                      Center(
                        child: Image.asset(
                          'assets/Recurso 3.png', // Path to your logo image
                          height: 100, // Adjust height as needed
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Horario de Clases',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      // Display a message if no subjects are enrolled, using a ternary operator
                      (_currentInscripcion == null ||
                              _currentInscripcion!.materiasInscritas.isEmpty)
                          ? const Text(
                              'No tienes materias inscritas para este semestre.',
                              style: TextStyle(fontSize: 16),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: _currentInscripcion!
                                    .materiasInscritas.length,
                                itemBuilder: (context, index) {
                                  final materia = _currentInscripcion!
                                      .materiasInscritas[index];
                                  // Display each subject and its schedule details
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0),
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
                                          // Display each day and time for the subject, using a ternary operator
                                          (materia.horarioClase['dia'] !=
                                                      null &&
                                                  materia.horarioClase[
                                                          'hora_inicio'] !=
                                                      null &&
                                                  materia.horarioClase[
                                                          'hora_fin'] !=
                                                      null)
                                              ? Text(
                                                  'Horario: ${materia.horarioClase['dia']} ${materia.horarioClase['hora_inicio']}-${materia.horarioClase['hora_fin']}')
                                              : const Text(
                                                  'Horario no disponible'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                      const SizedBox(height: 20),
                      // Button to download the schedule PDF
                      if (_currentInscripcion != null &&
                          _currentInscripcion!.materiasInscritas.isNotEmpty)
                        Center(
                          // Center the button
                          child: ElevatedButton.icon(
                            onPressed: _generateAndDownloadSchedulePdf,
                            icon: const Icon(Icons.download),
                            label: const Text('Descarga tu horario'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}