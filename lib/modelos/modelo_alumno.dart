import 'package:cloud_firestore/cloud_firestore.dart';

class Alumno {
  final String uid; // Firebase Auth UID
  final String nombre;
  final String apellido;
  final String matricula;
  final String curp;
  final DateTime fechaNacimiento;
  final String correoInstitucional;
  final String telefono;
  final String entidad;
  final String colonia;
  final String municipio;
  final String calle;
  final String? idGrupoActual; // Puede ser nulo al principio
  final String? idSemestreActual; // Puede ser nulo al principio

  Alumno({
    required this.uid,
    required this.nombre,
    required this.apellido,
    required this.matricula,
    required this.curp,
    required this.fechaNacimiento,
    required this.correoInstitucional,
    required this.telefono,
    required this.entidad,
    required this.colonia,
    required this.municipio,
    required this.calle,
    this.idGrupoActual,
    this.idSemestreActual,
  });

  factory Alumno.fromFirestore(Map<String, dynamic> data, String id) {
    return Alumno(
      uid: id,
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      matricula: data['matricula'] ?? '',
      curp: data['curp'] ?? '',
      fechaNacimiento: (data['fecha_nacimiento'] as Timestamp).toDate(),
      correoInstitucional: data['correo_institucional'] ?? '',
      telefono: data['telefono'] ?? '',
      entidad: data['entidad'] ?? '',
      colonia: data['colonia'] ?? '',
      municipio: data['municipio'] ?? '',
      calle: data['calle'] ?? '',
      idGrupoActual: data['id_grupo_actual'],
      idSemestreActual: data['id_semestre_actual'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'matricula': matricula,
      'curp': curp,
      'fecha_nacimiento': Timestamp.fromDate(fechaNacimiento),
      'correo_institucional': correoInstitucional,
      'telefono': telefono,
      'entidad': entidad,
      'colonia': colonia,
      'municipio': municipio,
      'calle': calle,
      'id_grupo_actual': idGrupoActual,
      'id_semestre_actual': idSemestreActual,
    };
  }
}
