// lib/models/modelo_inscripcion.dart (MODIFICADO SIGNIFICATIVAMENTE)
import 'package:cloud_firestore/cloud_firestore.dart';

// Nueva clase para representar cada materia inscrita dentro de una inscripción
class MateriaInscrita {
  final String
      idOfertaAcademica; // Referencia al documento en 'oferta_academica'
  final String idAsignatura;
  final String nombreAsignatura;
  final String numeroEmpleadoIngeniero;
  final String nombreIngeniero;
  final Map<String, dynamic> horarioClase; // Copia del horario de esa oferta

  MateriaInscrita({
    required this.idOfertaAcademica,
    required this.idAsignatura,
    required this.nombreAsignatura,
    required this.numeroEmpleadoIngeniero,
    required this.nombreIngeniero,
    required this.horarioClase,
  });

  factory MateriaInscrita.fromMap(Map<String, dynamic> data) {
    return MateriaInscrita(
      idOfertaAcademica: data['id_oferta_academica'] ?? '',
      idAsignatura: data['id_asignatura'] ?? '',
      nombreAsignatura: data['nombre_asignatura'] ?? '',
      numeroEmpleadoIngeniero: data['numero_empleado_ingeniero'] ?? '',
      nombreIngeniero: data['nombre_ingeniero'] ?? '',
      horarioClase: Map<String, dynamic>.from(data['horario_clase'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_oferta_academica': idOfertaAcademica,
      'id_asignatura': idAsignatura,
      'nombre_asignatura': nombreAsignatura,
      'numero_empleado_ingeniero': numeroEmpleadoIngeniero,
      'nombre_ingeniero': nombreIngeniero,
      'horario_clase': horarioClase,
    };
  }
}

class Inscripcion {
  final String
      idInscripcion; // Firestore document ID (puede ser vacío al crear)
  final String matriculaAlumno; // Usar la matrícula para el alumno
  final String idGrupo; // Referencia al ID del grupo seleccionado
  final String idSemestre; // Referencia al ID del semestre seleccionado
  final Timestamp fechaInscripcion;
  final List<MateriaInscrita> materiasInscritas; // LISTA DE MATERIAS INSCRITAS

  Inscripcion({
    required this.idInscripcion, // Pasar '' si es una nueva inscripción y Firestore generará uno
    required this.matriculaAlumno,
    required this.idGrupo,
    required this.idSemestre,
    required this.fechaInscripcion,
    required this.materiasInscritas,
  });

  factory Inscripcion.fromFirestore(Map<String, dynamic> data, String id) {
    var materiasList = data['materias_inscritas'] as List<dynamic>? ?? [];
    List<MateriaInscrita> parsedMaterias = materiasList
        .map((materia) =>
            MateriaInscrita.fromMap(materia as Map<String, dynamic>))
        .toList();

    return Inscripcion(
      idInscripcion: id,
      matriculaAlumno: data['matricula_alumno'] ?? '',
      idGrupo: data['id_grupo'] ?? '',
      idSemestre: data['id_semestre'] ?? '',
      fechaInscripcion: data['fecha_inscripcion'] as Timestamp,
      materiasInscritas: parsedMaterias,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'matricula_alumno': matriculaAlumno,
      'id_grupo': idGrupo,
      'id_semestre': idSemestre,
      'fecha_inscripcion': fechaInscripcion,
      'materias_inscritas': materiasInscritas
          .map((m) => m.toMap())
          .toList(), // Convertir lista de objetos a lista de Maps
    };
  }
}
