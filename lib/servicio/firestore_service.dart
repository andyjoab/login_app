// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/modelo_alumno.dart';
import '../modelos/modelo_asignatura.dart'; // Solo si vas a usar el catálogo base
import '../modelos/modelo_grupo.dart';
import '../modelos/modelo_inscripcion.dart'; // Asegúrate de que este es el modelo MODIFICADO
import '../modelos/modelo_semestre.dart'; // Asegúrate de que este es el modelo con 'activo'
import '../modelos/modelo_ofertaacademica.dart'; // Nuevo modelo
import '../modelos/modelo_calificacion.dart'; // Nuevo modelo

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Operaciones para Alumnos ---
  // Obtener un alumno por su UID (que debería ser el ID del documento en Firestore)
  Future<Alumno?> getAlumno(String uid) async {
    try {
      final doc = await _db.collection('alumnos').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return Alumno.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error al obtener alumno: $e');
      return null;
    }
  }

  // Añadir un nuevo alumno
  Future<void> addAlumno(Alumno alumno) async {
    try {
      // Usar el UID del alumno como ID del documento
      await _db.collection('alumnos').doc(alumno.uid).set(alumno.toFirestore());
    } catch (e) {
      print('Error al agregar alumno: $e');
      rethrow; // Relanza la excepción para que la UI pueda manejarla
    }
  }

  // Actualizar datos de un alumno
  Future<void> updateAlumno(Alumno alumno) async {
    try {
      await _db
          .collection('alumnos')
          .doc(alumno.uid)
          .update(alumno.toFirestore());
    } catch (e) {
      print('Error al actualizar alumno: $e');
      rethrow;
    }
  }

  // --- Operaciones para Semestres ---
  // Obtener todos los semestres
  Stream<List<Semestre>> getSemestres() {
    return _db.collection('semestres').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => Semestre.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  // Obtener solo los semestres activos para reinscripción
  Stream<List<Semestre>> getSemestresActivos() {
    return _db
        .collection('semestres')
        .where('activo', isEqualTo: true) // Filtra por el campo 'activo'
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Semestre.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // --- Operaciones para Grupos ---
  Stream<List<Grupo>> getGruposPorSemestre(String idSemestre) {
    return _db
        .collection('grupos')
        .where('id_semestre', isEqualTo: idSemestre)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Grupo.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // --- Operaciones para Oferta Académica ---
  // Obtener la oferta académica para un semestre y grupo específico
  Stream<List<OfertaAcademica>> getOfertaAcademicaPorGrupoYSemestre(
      String idSemestre, String idGrupo) {
    return _db
        .collection('oferta_academica')
        .where('id_semestre', isEqualTo: idSemestre)
        .where('id_grupo', isEqualTo: idGrupo)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OfertaAcademica.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // --- Operaciones para Inscripciones (Reinscripción) ---
  Future<void> registrarInscripcion(Inscripcion inscripcion) async {
    try {
      // Firestore generará un ID de documento único automáticamente con add()
      await _db.collection('inscripciones').add(inscripcion.toFirestore());
    } catch (e) {
      print('Error al registrar inscripción: $e');
      rethrow;
    }
  }

  // Obtener las inscripciones de un alumno (para historial y horario)
  Stream<List<Inscripcion>> getInscripcionesPorAlumno(String matriculaAlumno) {
    return _db
        .collection('inscripciones')
        .where('matricula_alumno', isEqualTo: matriculaAlumno)
        .orderBy('fecha_inscripcion',
            descending: true) // Obtener la más reciente primero
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Inscripcion.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // --- Operaciones para Calificaciones ---
  Future<void> addCalificacion(Calificacion calificacion) async {
    try {
      await _db.collection('calificaciones').add(calificacion.toFirestore());
    } catch (e) {
      print('Error al agregar calificación: $e');
      rethrow;
    }
  }

  // Obtener calificaciones de un alumno
  Stream<List<Calificacion>> getCalificacionesPorAlumno(
      String matriculaAlumno) {
    return _db
        .collection('calificaciones')
        .where('matricula_alumno', isEqualTo: matriculaAlumno)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Calificacion.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Obtener calificaciones de un alumno por semestre específico
  Stream<List<Calificacion>> getCalificacionesPorAlumnoYSemestre(
      String matriculaAlumno, String idSemestre) {
    return _db
        .collection('calificaciones')
        .where('matricula_alumno', isEqualTo: matriculaAlumno)
        .where('id_semestre', isEqualTo: idSemestre)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Calificacion.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // También puedes añadir operaciones para ingenieros si es necesario
}
