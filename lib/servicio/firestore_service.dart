// lib/servicio/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/modelo_alumno.dart';
import '../modelos/modelo_asignatura.dart'; // Solo si vas a usar el catálogo base
import '../modelos/modelo_grupo.dart';
import '../modelos/modelo_inscripcion.dart'; // ASEGÚRATE de que este es el modelo MODIFICADO con 'uidAlumno'
import '../modelos/modelo_semestre.dart'; // Asegúrate de que este es el modelo con 'activo'
import '../modelos/modelo_ofertaacademica.dart'; // Nuevo modelo
import '../modelos/modelo_calificacion.dart'; // Nuevo modelo

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener un alumno por su UID (que debería ser el ID del documento en Firestore)
  Future<Alumno?> getAlumnoData(String uid) async {
    try {
      final doc = await _db.collection('alumnos').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return Alumno.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error al obtener datos del alumno: $e');
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

  // Actualizar datos de un alumno usando el objeto Alumno completo
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

  // Nuevo método para actualizar campos específicos del alumno
  // Esto es útil para actualizar solo 'id_grupo_actual' y 'id_semestre_actual'
  Future<void> updateAlumnoData(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('alumnos').doc(uid).update(data);
    } catch (e) {
      print('Error al actualizar datos específicos del alumno: $e');
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

  // Método para crear una nueva inscripción
  // Usará el ID que ya viene en el objeto 'inscripcion' si fue generado previamente
  // (por ejemplo, con FirebaseFirestore.instance.collection('inscripciones').doc().id)
  Future<void> createInscripcion(Inscripcion inscripcion) async {
    try {
      await _db
          .collection('inscripciones')
          .doc(inscripcion.idInscripcion) // Usa el ID del objeto Inscripcion
          .set(inscripcion.toFirestore());
    } catch (e) {
      print('Error al crear inscripción: $e');
      rethrow;
    }
  }

  // Método para actualizar una inscripción existente
  Future<void> updateInscripcion(
      String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection('inscripciones').doc(docId).update(data);
    } catch (e) {
      print('Error al actualizar inscripción: $e');
      rethrow;
    }
  }

  // Obtener las inscripciones de un alumno (para historial y horario)
  // Nota: Considera añadir un filtro por UID del alumno aquí también, si tus reglas de seguridad lo requieren para lecturas.
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
