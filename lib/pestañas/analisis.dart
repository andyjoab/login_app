import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:login_app/modelos/modelo_calificacion.dart';
import 'package:login_app/modelos/modelo_alumno.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // Import SpeedDial

class GradesAnalysisScreen extends StatefulWidget {
  const GradesAnalysisScreen({super.key});

  @override
  State<GradesAnalysisScreen> createState() => _GradesAnalysisScreenState();
}

class _GradesAnalysisScreenState extends State<GradesAnalysisScreen> {
  String? _userMatricula;
  bool _isLoading = true;
  List<Calificacion> _grades = [];
  String? _errorMessage;
  Alumno? _currentAlumno;

  final int _fixedTotalCareerCourses = 50;
  String? _selectedSemester;

  @override
  void initState() {
    super.initState();
    _fetchStudentAndGrades();
  }

  Future<void> _fetchStudentAndGrades() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Usuario no autenticado.';
        _isLoading = false;
      });
      return;
    }

    try {
      final alumnoDoc = await FirebaseFirestore.instance
          .collection('alumnos')
          .doc(user.uid)
          .get();

      if (alumnoDoc.exists) {
        _currentAlumno = Alumno.fromFirestore(alumnoDoc.data()!, alumnoDoc.id);
        _userMatricula = _currentAlumno!.matricula;

        if (_userMatricula != null) {
          final gradesQuery = await FirebaseFirestore.instance
              .collection('calificaciones')
              .where('matricula', isEqualTo: _userMatricula)
              .orderBy('id_semestre', descending: false)
              .orderBy('nombre_asignatura', descending: false)
              .get();

          _grades = gradesQuery.docs
              .map((doc) => Calificacion.fromFirestore(doc.data(), doc.id))
              .toList();

          if (_grades.isEmpty) {
            _errorMessage = 'No se encontraron calificaciones para graficar.';
          } else {
            if (_grades.isNotEmpty) {
              _selectedSemester = _grades.last.idSemestre;
            }
          }
        } else {
          _errorMessage = 'No se pudo obtener la matrícula del alumno.';
        }
      } else {
        _errorMessage = 'No se encontró el perfil del alumno.';
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      _errorMessage = 'Error al cargar los datos: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  LineChartData mainData() {
    if (_grades.isEmpty) {
      return LineChartData();
    }

    Map<String, List<Calificacion>> gradesBySemester = {};
    for (var grade in _grades) {
      gradesBySemester.update(
        grade.idSemestre ?? 'Desconocido',
        (list) => list..add(grade),
        ifAbsent: () => [grade],
      );
    }

    List<String> sortedSemesters = gradesBySemester.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    List<FlSpot> spots = [];
    List<String> bottomTitles = [];
    double maxY = 0;
    double minY = 100;

    for (int i = 0; i < sortedSemesters.length; i++) {
      String semester = sortedSemesters[i];
      List<Calificacion> semesterGrades = gradesBySemester[semester]!;

      double averageGrade = semesterGrades
              .map((g) => g.calificacionFinal)
              .fold(0.0, (prev, element) => prev + element) /
          semesterGrades.length;

      spots.add(FlSpot(i.toDouble(), averageGrade));
      if (averageGrade > maxY) maxY = averageGrade;
      if (averageGrade < minY) minY = averageGrade;
    }

    if (maxY < 100) maxY = (maxY + 5).clamp(0, 100);
    if (minY > 0) minY = (minY - 5).clamp(0, 100);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 10,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color.fromARGB(255, 78, 170, 245),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color.fromARGB(255, 91, 166, 228),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < bottomTitles.length) {
                return SideTitleWidget(
                  space: 8.0,
                  meta: meta,
                  child: Transform.rotate(
                    angle: 45 * (3.1415926535 / 180),
                    child: Text(bottomTitles[value.toInt()],
                        style: const TextStyle(
                            color: Color.fromARGB(255, 3, 92, 175),
                            fontWeight: FontWeight.bold,
                            fontSize: 10)),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
            getTitlesWidget: (value, meta) {
              return Text(value.toStringAsFixed(0),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 12, 129, 245),
                      fontWeight: FontWeight.bold,
                      fontSize: 10));
            },
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
            color: const Color.fromARGB(255, 16, 193, 224), width: 1),
      ),
      minX: 0,
      maxX: (sortedSemesters.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.3),
                Theme.of(context).colorScheme.secondary.withOpacity(0.3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PieChartData careerProgressData() {
    final int coursesTaken = _grades.length;
    final int coursesRemaining = _fixedTotalCareerCourses - coursesTaken;

    double takenPercentage = 0.0;
    double remainingPercentage = 0.0;

    if (_fixedTotalCareerCourses > 0) {
      takenPercentage = (coursesTaken / _fixedTotalCareerCourses) * 100;
      remainingPercentage = (coursesRemaining / _fixedTotalCareerCourses) * 100;
    }

    return PieChartData(
      sections: [
        PieChartSectionData(
          color: Colors.green,
          value: takenPercentage,
          title: '${takenPercentage.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          badgeWidget: Text(
            'Cursadas\n(${coursesTaken})',
            textAlign: TextAlign.center,
          ),
          badgePositionPercentageOffset: 1.2,
        ),
        PieChartSectionData(
          color: Colors.red,
          value: remainingPercentage,
          title: '${remainingPercentage.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          badgeWidget: Text(
            'Restantes\n(${coursesRemaining < 0 ? 0 : coursesRemaining})',
            textAlign: TextAlign.center,
          ),
          badgePositionPercentageOffset: 1.2,
        ),
      ],
      sectionsSpace: 0,
      centerSpaceRadius: 40,
    );
  }

  Future<pw.MemoryImage> _loadImage(String path) async {
    final ByteData bytes = await rootBundle.load(path);
    return pw.MemoryImage(bytes.buffer.asUint8List());
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    if (_currentAlumno == null || _grades.isEmpty) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text(
                  'No hay datos disponibles para generar el historial académico.',
                  style: pw.TextStyle(fontSize: 16)),
            );
          },
        ),
      );
      return pdf.save();
    }

    final tecNmLogo = await _loadImage('assets/Logo-TecNM-2017.png');
    final tesTLogo = await _loadImage('assets/TesT.png');

    Map<String, List<Calificacion>> gradesBySemester = {};
    for (var grade in _grades) {
      gradesBySemester.update(
        grade.idSemestre ?? 'Semestre Desconocido',
        (list) => list..add(grade),
        ifAbsent: () => [grade],
      );
    }

    List<String> sortedSemesters = gradesBySemester.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    double overallAverage = 0.0;
    if (_grades.isNotEmpty) {
      overallAverage =
          _grades.map((g) => g.calificacionFinal).reduce((a, b) => a + b) /
              _grades.length;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(tecNmLogo, width: 80, height: 80),
                  pw.Column(
                    children: [
                      pw.Text('Acta de Historial Académico',
                          style: pw.TextStyle(
                              fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Tecnológico de Estudios Superiores de Tianguistenco',
                          style: const pw.TextStyle(fontSize: 12)),
                    ]
                  ),
                  pw.Image(tesTLogo, width: 80, height: 80),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                  'Fecha de Emisión: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}'),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Datos del Alumno:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  'Nombre: ${_currentAlumno!.nombre} ${_currentAlumno!.apellido}'),
              pw.Text('Matrícula: ${_currentAlumno!.matricula}'),
              pw.Text(
                  'Correo Institucional: ${_currentAlumno!.correoInstitucional}'),

              pw.SizedBox(height: 20),
              pw.Text('Resumen Académico:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Total de Asignaturas Cursadas: ${_grades.length}'),
              pw.Text(
                  'Total de Asignaturas en la Carrera: $_fixedTotalCareerCourses'),
              pw.Text('Promedio General: ${overallAverage.toStringAsFixed(2)}'),
              pw.SizedBox(height: 20),

              pw.Text('Detalle por Semestre:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              for (var semester in sortedSemesters)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Semestre: $semester',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 14)),
                    pw.SizedBox(height: 5),
                    pw.Table.fromTextArray(
                      headers: ['Asignatura', 'Ingeniero', 'Calificación'],
                      data: gradesBySemester[semester]!
                          .map((g) => [
                                g.nombreAsignatura,
                                g.nombreIngeniero,
                                g.calificacionFinal.toStringAsFixed(1),
                              ])
                          .toList(),
                      border: pw.TableBorder.all(color: PdfColors.grey),
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      cellAlignment: pw.Alignment.centerLeft,
                      cellPadding: const pw.EdgeInsets.all(5),
                    ),
                    pw.SizedBox(height: 15),
                  ],
                ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> _generatePartialGradesPdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    if (_currentAlumno == null ||
        _grades.isEmpty ||
        _selectedSemester == null) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text(
                  'No hay datos suficientes para generar el acta de calificaciones parciales o no se ha seleccionado un semestre.',
                  style: pw.TextStyle(fontSize: 16)),
            );
          },
        ),
      );
      return pdf.save();
    }

    final tecNmLogo = await _loadImage('assets/Logo-TecNM-2017.png');
    final tesTLogo = await _loadImage('assets/TesT.png');

    final partialGrades = _grades
        .where((grade) => grade.idSemestre == _selectedSemester)
        .toList();

    if (partialGrades.isEmpty) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text(
                  'No se encontraron calificaciones para el semestre seleccionado: $_selectedSemester',
                  style: pw.TextStyle(fontSize: 16)),
            );
          },
        ),
      );
      return pdf.save();
    }

    double semesterAverage = 0.0;
    if (partialGrades.isNotEmpty) {
      semesterAverage = partialGrades
              .map((g) => g.calificacionFinal)
              .reduce((a, b) => a + b) /
          partialGrades.length;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(tecNmLogo, width: 80, height: 80),
                  pw.Column(
                    children: [
                      pw.Text('Acta de Calificaciones Parciales',
                          style: pw.TextStyle(
                              fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Tecnológico de Estudios Superiores de Tianguistenco',
                          style: const pw.TextStyle(fontSize: 12)),
                    ]
                  ),
                  pw.Image(tesTLogo, width: 80, height: 80),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                  'Fecha de Emisión: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}'),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Datos del Alumno:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  'Nombre: ${_currentAlumno!.nombre} ${_currentAlumno!.apellido}'),
              pw.Text('Matrícula: ${_currentAlumno!.matricula}'),
              pw.Text(
                  'Correo Institucional: ${_currentAlumno!.correoInstitucional}'),
              pw.SizedBox(height: 20),
              pw.Text('Semestre Actual: $_selectedSemester',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.Text('Promedio del Semestre: ${semesterAverage.toStringAsFixed(2)}'),
              pw.SizedBox(height: 10),
              pw.Text('Detalle de Calificaciones:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Table.fromTextArray(
                headers: ['Asignatura', 'Ingeniero', 'Calificación'],
                data: partialGrades
                    .map((g) => [
                          g.nombreAsignatura,
                          g.nombreIngeniero,
                          g.calificacionFinal.toStringAsFixed(1),
                        ])
                    .toList(),
                border: pw.TableBorder.all(color: PdfColors.grey),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(5),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> availableSemesters = _grades
        .map((g) => g.idSemestre)
        .where((s) => s != null)
        .cast<String>()
        .toSet()
        .toList()
          ..sort((a, b) => a.compareTo(b));

    return Scaffold(
      backgroundColor: Colors.white,
      //appBar: AppBar(
        //title: const Text('Dashboard de calificaciones'),
        //backgroundColor: Colors.white,
        //foregroundColor: Colors.black,
      //),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                )
              : _grades.isEmpty && _fixedTotalCareerCourses == 0
                  ? const Center(
                      child: Text('No hay datos disponibles para el análisis.'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Promedio por Semestre',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          AspectRatio(
                            aspectRatio: 1.70,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 18,
                                left: 12,
                                top: 24,
                                bottom: 12,
                              ),
                              child: LineChart(mainData()),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Progreso de Carrera',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          AspectRatio(
                            aspectRatio: 1.3,
                            child: PieChart(careerProgressData()),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Calificación por Asignatura',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _grades.length,
                            itemBuilder: (context, index) {
                              final grade = _grades[index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                elevation: 2,
                                child: ListTile(
                                  title: Text(grade.nombreAsignatura),
                                  subtitle: Text(
                                      ' ${grade.idSemestre ?? 'N/A'} | Ingeniero: ${grade.nombreIngeniero}'),
                                  trailing: Chip(
                                    label: Text(
                                      grade.calificacionFinal.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: grade.calificacionFinal > 70
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    backgroundColor:
                                        grade.calificacionFinal > 70
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (availableSemesters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
              child: SizedBox(
                width: 250,
                child: DropdownButtonFormField<String>(
                  value: _selectedSemester,
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar Semestre',
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: availableSemesters.map((String semester) {
                    return DropdownMenuItem<String>(
                      value: semester,
                      child: Text(semester),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSemester = newValue;
                    });
                  },
                ),
              ),
            ),
          SpeedDial(
            icon: Icons.menu_book,
            activeIcon: Icons.close,
            spacing: 3,
            buttonSize: const Size(56.0, 56.0),
            direction: SpeedDialDirection.up,
            renderOverlay: true,
            overlayColor: Colors.black,
            overlayOpacity: 0.5,
            visible: true,
            curve: Curves.bounceIn,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 8.0,
            shape: const CircleBorder(),
            children: [
              SpeedDialChild(
                child: const Icon(Icons.download),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                label: 'Descargar Historial Académico',
                labelStyle: const TextStyle(fontSize: 14.0),
                onTap: () {
                  if (!_isLoading && _errorMessage == null && _grades.isNotEmpty) {
                    Printing.layoutPdf(
                      onLayout: _generatePdf,
                      name:
                          'Historial_Academico_${_currentAlumno?.matricula ?? 'Desconocido'}.pdf',
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'No hay datos suficientes para generar el PDF o los datos se están cargando.')),
                    );
                  }
                },
              ),
              SpeedDialChild(
                child: const Icon(Icons.description),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                label: 'Descargar Acta de Calificaciones Parciales',
                labelStyle: const TextStyle(fontSize: 14.0),
                onTap: () {
                  if (!_isLoading &&
                      _errorMessage == null &&
                      _grades.isNotEmpty &&
                      _selectedSemester != null) {
                    Printing.layoutPdf(
                      onLayout: _generatePartialGradesPdf,
                      name:
                          'Acta_Parcial_${_currentAlumno?.matricula ?? 'Desconocido'}_Semestre_${_selectedSemester}.pdf',
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'No hay datos suficientes o semestre seleccionado para generar el Acta Parcial.')),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}