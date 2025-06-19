//import 'package:cloud_firestore/cloud_firestore.dart'; // Importar por si acaso se usara Timestamp

class Semestre {
  final String idSemestre; // Corresponds to Firestore document ID
  final String nombreSemestre; // Corresponds to 'nombre_semestre' field
  final bool
      activo; //  para indicar si el semestre está activo para reinscripción

  Semestre({
    required this.idSemestre,
    required this.nombreSemestre,
    this.activo = true, // Valor por defecto en Dart
  });

  factory Semestre.fromFirestore(Map<String, dynamic> data, String id) {
    return Semestre(
      idSemestre: id,
      nombreSemestre: data['nombre_semestre'] ?? '',
      activo: data['activo'] ?? false, // Lee el campo 'activo'
    );
  }

  // Método para convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre_semestre': nombreSemestre,
      'activo': activo,
    };
  }
}
