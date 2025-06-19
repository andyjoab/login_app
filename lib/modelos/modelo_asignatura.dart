//import 'package:cloud_firestore/cloud_firestore.dart';

class Asignatura {
  final String idAsignatura; // Firestore document ID
  final String nombreAsignatura; // Nombre de la asignatura

  Asignatura({
    required this.idAsignatura,
    required this.nombreAsignatura,
  });

  factory Asignatura.fromFirestore(Map<String, dynamic> data, String id) {
    return Asignatura(
      idAsignatura: id,
      nombreAsignatura: data['nombre_asignatura'] ?? '',
    );
  }

  // Método para convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre_asignatura': nombreAsignatura,
    };
  }
}
