import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para Timestamp
import 'package:firebase_auth/firebase_auth.dart'; // Para obtener el UID del usuario
import 'package:login_app/servicio/firestore_service.dart'; // Importa tu FirestoreService
import 'package:login_app/modelos/modelo_ofertaacademica.dart'; // Importa el modelo de OfertaAcademica
import 'package:login_app/modelos/modelo_inscripcion.dart'; // Importa el modelo de Inscripcion (ya con MateriaInscrita)
import 'package:login_app/modelos/modelo_alumno.dart'; // Para obtener la matrícula del alumno

class Seleccion_Asignaturas extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String semesterId;
  final String semesterName;

  const Seleccion_Asignaturas({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.semesterId,
    required this.semesterName,
  });

  @override
  State<Seleccion_Asignaturas> createState() => _Seleccion_AsignaturasState();
}

class _Seleccion_AsignaturasState extends State<Seleccion_Asignaturas> {
  final FirestoreService _firestoreService = FirestoreService();
  final List<OfertaAcademica> _selectedMaterias = [];
  String?
      _currentAlumnoMatricula; // Para almacenar la matrícula del alumno actual

  @override
  void initState() {
    super.initState();
    _loadCurrentAlumnoMatricula(); // Cargar la matrícula al iniciar
  }

  Future<void> _loadCurrentAlumnoMatricula() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Asumiendo que el UID de Firebase Auth es el ID del documento del alumno
      Alumno? alumno = await _firestoreService.getAlumno(currentUser.uid);
      if (alumno != null) {
        setState(() {
          _currentAlumnoMatricula = alumno.matricula;
        });
      } else {
        print(
            'Error: No se encontró el perfil del alumno para el UID ${currentUser.uid}');
        // Manejar el caso donde el alumno no tiene perfil en Firestore
        _showErrorSnackBar(
            'No se pudo cargar la matrícula del alumno. Contacte a soporte.');
      }
    } else {
      print('Error: Usuario no autenticado.');
      // Redirigir al login si no hay usuario
      _showErrorSnackBar('Debes iniciar sesión para reinscribirte.');
      Navigator.of(context)
          .popUntil((route) => route.isFirst); // Vuelve al inicio o login
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _confirmSelection() async {
    if (_selectedMaterias.isEmpty) {
      _showErrorSnackBar('Por favor, selecciona al menos una materia.');
      return;
    }

    if (_currentAlumnoMatricula == null) {
      _showErrorSnackBar(
          'No se pudo obtener la matrícula del alumno. Intenta de nuevo.');
      return;
    }

    // Mapear las OfertaAcademica seleccionadas a MateriaInscrita
    List<MateriaInscrita> materiasParaInscripcion =
        _selectedMaterias.map((oferta) {
      return MateriaInscrita(
        idOfertaAcademica: oferta.idOfertaAcademica,
        idAsignatura: oferta.idAsignatura,
        nombreAsignatura: oferta.nombreAsignatura,
        numeroEmpleadoIngeniero: oferta.numeroEmpleadoIngeniero,
        nombreIngeniero: oferta.nombreIngeniero,
        horarioClase: oferta.horario,
      );
    }).toList();

    // Crear la instancia de Inscripcion
    final nuevaInscripcion = Inscripcion(
      idInscripcion: '', // Firestore generará este ID
      matriculaAlumno: _currentAlumnoMatricula!,
      idGrupo: widget.groupId,
      idSemestre: widget.semesterId,
      fechaInscripcion: Timestamp.now(),
      materiasInscritas: materiasParaInscripcion,
    );

    try {
      await _firestoreService.registrarInscripcion(nuevaInscripcion);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reinscripción registrada con éxito!'),
          backgroundColor: Color.fromARGB(255, 120, 239, 255),
        ),
      );
      // Opcional: Navegar a una pantalla de confirmación o volver al menú principal
      Navigator.of(context)
          .popUntil((route) => route.isFirst); // Regresa al inicio
    } catch (e) {
      print('Error al registrar reinscripción: $e');
      _showErrorSnackBar('Error al registrar reinscripción: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.groupName} - ${widget.semesterName}'), //('Materias de ${widget.groupName} - ${widget.semesterName}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Selecciona las materias',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            // StreamBuilder para obtener la oferta académica en tiempo real
            child: StreamBuilder<List<OfertaAcademica>>(
              stream: _firestoreService.getOfertaAcademicaPorGrupoYSemestre(
                  widget.semesterId, widget.groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print("Error al cargar oferta académica: ${snapshot.error}");
                  return Center(
                      child:
                          Text('Error al cargar materias: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text(
                          'No hay materias ofertadas para este grupo y semestre.'));
                }

                final ofertaAcademica = snapshot.data!;
                return ListView.builder(
                  itemCount: ofertaAcademica.length,
                  itemBuilder: (context, index) {
                    final oferta = ofertaAcademica[index];
                    final isSelected = _selectedMaterias.contains(oferta);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      elevation: 3,
                      child: CheckboxListTile(
                        title: Text(oferta.nombreAsignatura,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Ing. ${oferta.nombreIngeniero}\nHorario: ${oferta.horario.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedMaterias.add(oferta);
                            } else {
                              _selectedMaterias.remove(oferta);
                            }
                          });
                        },
                        secondary: isSelected
                            ? const Icon(Icons.check_circle,
                                color: Color.fromARGB(255, 96, 207, 202))
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _confirmSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'Confirmar Selección',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
