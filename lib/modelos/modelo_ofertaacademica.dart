// lib/models/modelo_ofertaacademica.dart
//import 'package:cloud_firestore/cloud_firestore.dart';

class OfertaAcademica {
  final String idOfertaAcademica; // Document ID
  final String idAsignatura;
  final String nombreAsignatura;
  final String numeroEmpleadoIngeniero;
  final String nombreIngeniero;
  final String idGrupo;
  final String idSemestre;
  final Map<String, dynamic> horario; // Ej: {'lunes': '08:00-09:00'}

  OfertaAcademica({
    required this.idOfertaAcademica,
    required this.idAsignatura,
    required this.nombreAsignatura,
    required this.numeroEmpleadoIngeniero,
    required this.nombreIngeniero,
    required this.idGrupo,
    required this.idSemestre,
    required this.horario,
  });

  factory OfertaAcademica.fromFirestore(Map<String, dynamic> data, String id) {
    return OfertaAcademica(
      idOfertaAcademica: id,
      idAsignatura: data['id_asignatura'] ?? '',
      nombreAsignatura: data['nombre_asignatura'] ?? '',
      numeroEmpleadoIngeniero: data['numero_empleado_ingeniero'] ?? '',
      nombreIngeniero: data['nombre_ingeniero'] ?? '',
      idGrupo: data['id_grupo'] ?? '',
      idSemestre: data['id_semestre'] ?? '',
      horario: Map<String, dynamic>.from(data['horario'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id_asignatura': idAsignatura,
      'nombre_asignatura': nombreAsignatura,
      'numero_empleado_ingeniero': numeroEmpleadoIngeniero,
      'nombre_ingeniero': nombreIngeniero,
      'id_grupo': idGrupo,
      'id_semestre': idSemestre,
      'horario': horario,
    };
  }
}
