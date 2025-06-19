// lib/models/modelo_calificacion.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Calificacion {
  final String idCalificacion;
  final String matriculaAlumno;
  final String
      idOfertaAcademica; // Para vincular a la instancia de clase específica
  final String idAsignatura;
  final String nombreAsignatura;
  final String numeroEmpleadoIngeniero;
  final String nombreIngeniero;
  final double calificacionFinal;
  final Timestamp fechaRegistro;
  final String?
      idSemestre; // Para facilitar consultas de calificaciones por semestre

  Calificacion({
    required this.idCalificacion,
    required this.matriculaAlumno,
    required this.idOfertaAcademica,
    required this.idAsignatura,
    required this.nombreAsignatura,
    required this.numeroEmpleadoIngeniero,
    required this.nombreIngeniero,
    required this.calificacionFinal,
    required this.fechaRegistro,
    this.idSemestre,
  });

  factory Calificacion.fromFirestore(Map<String, dynamic> data, String id) {
    return Calificacion(
      idCalificacion: id,
      matriculaAlumno: data['matricula_alumno'] ?? '',
      idOfertaAcademica: data['id_oferta_academica'] ?? '',
      idAsignatura: data['id_asignatura'] ?? '',
      nombreAsignatura: data['nombre_asignatura'] ?? '',
      numeroEmpleadoIngeniero: data['numero_empleado_ingeniero'] ?? '',
      nombreIngeniero: data['nombre_ingeniero'] ?? '',
      calificacionFinal:
          (data['calificacion_final'] as num?)?.toDouble() ?? 0.0,
      fechaRegistro: data['fecha_registro'] as Timestamp,
      idSemestre: data['id_semestre'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'matricula_alumno': matriculaAlumno,
      'id_oferta_academica': idOfertaAcademica,
      'id_asignatura': idAsignatura,
      'nombre_asignatura': nombreAsignatura,
      'numero_empleado_ingeniero': numeroEmpleadoIngeniero,
      'nombre_ingeniero': nombreIngeniero,
      'calificacion_final': calificacionFinal,
      'fecha_registro': fechaRegistro,
      'id_semestre': idSemestre,
    };
  }
}
