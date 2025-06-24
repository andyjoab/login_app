import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? _currentAlumnoMatricula;
  String? _currentAlumnoUid; // <--- Nuevo: Para almacenar el UID del alumno
  bool _isLoadingAlumnoData = true; // Para saber si ya cargó la matrícula y UID

  @override
  void initState() {
    super.initState();
    _loadCurrentAlumnoData(); // Cargar la matrícula y UID al iniciar
  }

  Future<void> _loadCurrentAlumnoData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _currentAlumnoUid =
          currentUser.uid; // Asigna el UID del usuario autenticado

      // Asumiendo que el UID de Firebase Auth es el ID del documento del alumno
      // Asegúrate de que tu FirestoreService tenga un método getAlumnoData que use el UID
      Alumno? alumno = await _firestoreService.getAlumnoData(currentUser.uid);
      if (alumno != null) {
        setState(() {
          _currentAlumnoMatricula = alumno.matricula;
          _isLoadingAlumnoData = false;
        });
      } else {
        debugPrint(
            'Error: No se encontró el perfil del alumno para el UID ${currentUser.uid}');
        _showErrorSnackBar(
            'No se pudo cargar la matrícula del alumno. Contacte a soporte.');
        setState(() {
          _isLoadingAlumnoData = false;
        });
      }
    } else {
      debugPrint('Error: Usuario no autenticado.');
      _showErrorSnackBar('Debes iniciar sesión para reinscribirte.');
      // Redirigir al login si no hay usuario (asegúrate de que esta ruta exista)
      Navigator.of(context).popUntil((route) => route.isFirst);
      setState(() {
        _isLoadingAlumnoData = false;
      });
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

    if (_currentAlumnoMatricula == null || _currentAlumnoUid == null) {
      // <-- Verifica también _currentAlumnoUid
      _showErrorSnackBar(
          'No se pudo obtener la matrícula o UID del alumno. Intenta de nuevo.');
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
        horarioClase: oferta
            .horario, // Asume que OfertaAcademica ya tiene el horario en el formato correcto
      );
    }).toList();

    try {
      // Buscar una inscripción existente para el alumno en el semestre y grupo actual
      // AÑADIR FILTRO POR UID DEL ALUMNO para cumplir con las reglas de seguridad
      final existingInscripcionQuery = await FirebaseFirestore.instance
          .collection('inscripciones')
          .where('matricula_alumno', isEqualTo: _currentAlumnoMatricula!)
          .where('id_grupo', isEqualTo: widget.groupId)
          .where('id_semestre', isEqualTo: widget.semesterId)
          .where('uid_alumno',
              isEqualTo: _currentAlumnoUid!) //  Filtro por UID del alumno
          .limit(1)
          .get();

      if (existingInscripcionQuery.docs.isNotEmpty) {
        // Actualizar inscripción existente
        String inscriptionId = existingInscripcionQuery.docs.first.id;
        await _firestoreService.updateInscripcion(
          inscriptionId, // ID del documento a actualizar
          {
            'materias_inscritas':
                materiasParaInscripcion.map((m) => m.toMap()).toList(),
            'fecha_inscripcion': Timestamp.now(),
            'uid_alumno':
                _currentAlumnoUid, // Asegurar que el UID se mantiene/actualiza
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Inscripción actualizada exitosamente!')),
        );
      } else {
        // Crear nueva inscripción
        // Firestore generará el ID del documento si no se especifica
        final newInscripcionRef =
            FirebaseFirestore.instance.collection('inscripciones').doc();

        final nuevaInscripcion = Inscripcion(
          idInscripcion:
              newInscripcionRef.id, // Usar el ID generado por Firestore
          matriculaAlumno: _currentAlumnoMatricula!,
          idGrupo: widget.groupId,
          idSemestre: widget.semesterId,
          fechaInscripcion: Timestamp.now(),
          materiasInscritas: materiasParaInscripcion,
          uidAlumno:
              _currentAlumnoUid!, // <--- AÑADIDO: Asigna el UID del alumno aquí
        );

        await _firestoreService.createInscripcion(
            nuevaInscripcion); // Llama al servicio con el objeto completo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reinscripción creada exitosamente!')),
        );
      }

      // Opcional: Actualizar el id_grupo_actual y id_semestre_actual en el perfil del Alumno
      // Esto es útil para que el MainMenuScreen sepa cuál es la inscripción "activa"
      await _firestoreService.updateAlumnoData(
        _currentAlumnoUid!,
        {
          'id_grupo_actual': widget.groupId,
          'id_semestre_actual': widget.semesterId,
        },
      );

      // Navegar de vuelta al menú principal
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reinscripción completada.')),
      );
    } on FirebaseException catch (e) {
      debugPrint("Error de Firebase al registrar inscripción: ${e.message}");
      _showErrorSnackBar('Error de Firebase: ${e.message}');
    } catch (e) {
      debugPrint("Error general al registrar inscripción: $e");
      _showErrorSnackBar('Error al realizar la inscripción: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.groupName} - ${widget.semesterName}'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 39, 38, 38),
        ),
        foregroundColor: Colors.black,
      ),
      body:
          _isLoadingAlumnoData // Mostrar indicador de carga mientras se obtienen datos del alumno
              ? const Center(child: CircularProgressIndicator())
              : Column(
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
                        stream: _firestoreService
                            .getOfertaAcademicaPorGrupoYSemestre(
                                widget.semesterId, widget.groupId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            debugPrint(
                                "Error al cargar oferta académica: ${snapshot.error}");
                            return Center(
                                child: Text(
                                    'Error al cargar materias: ${snapshot.error}'));
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
                              final isSelected =
                                  _selectedMaterias.contains(oferta);
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                elevation: 3,
                                child: CheckboxListTile(
                                  title: Text(oferta.nombreAsignatura,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
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
                                          color:
                                              Color.fromARGB(255, 96, 207, 202))
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
