import 'package:cloud_firestore/cloud_firestore.dart';

class Calificacion {
  final String idCalificacion;
  final String matriculaAlumno; // Corresponde al campo 'matricula' en Firestore
  final String
      idOfertaAcademica; // Corresponde al campo 'idOfertaAcademica' en Firestore (camelCase)
  final String nombreAsignatura;
  final String
      numeroEmpleadoIngeniero; // Corresponde al campo 'numero_empleado' en Firestore
  final String nombreIngeniero;
  final double calificacionFinal;
  final Timestamp fechaRegistro;
  final String?
      idSemestre; // Este campo no se ve en tu captura de Firestore, asegúrate de que exista si lo usas

  Calificacion({
    required this.idCalificacion,
    required this.matriculaAlumno,
    required this.idOfertaAcademica,
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
      matriculaAlumno: data['matricula'] as String? ??
          '', // Corregido: 'matricula_alumno' -> 'matricula'
      idOfertaAcademica: data['idOfertaAcademica'] as String? ??
          '', // Corregido: 'id_oferta_academica' -> 'idOfertaAcademica'
      nombreAsignatura: data['nombre_asignatura'] as String? ?? '',
      numeroEmpleadoIngeniero: data['numero_empleado'] as String? ??
          '', // Corregido: 'numero_empleado_ingeniero' -> 'numero_empleado'
      nombreIngeniero: data['nombre_ingeniero'] as String? ?? '',
      calificacionFinal:
          (data['calificacion_final'] as num?)?.toDouble() ?? 0.0,
      fechaRegistro: data['fecha_registro'] as Timestamp? ?? Timestamp.now(),
      idSemestre: data['id_semestre']
          as String?, // Asegúrate de que este campo exista en Firestore si lo usas para ordenar
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'matricula':
          matriculaAlumno, // Corregido: 'matricula_alumno' -> 'matricula'
      'idOfertaAcademica':
          idOfertaAcademica, // Corregido: 'id_oferta_academica' -> 'idOfertaAcademica'
      'nombre_asignatura': nombreAsignatura,
      'numero_empleado':
          numeroEmpleadoIngeniero, // Corregido: 'numero_empleado_ingeniero' -> 'numero_empleado'
      'nombre_ingeniero': nombreIngeniero,
      'calificacion_final': calificacionFinal,
      'fecha_registro': fechaRegistro,
      'id_semestre': idSemestre,
    };
  }
}
