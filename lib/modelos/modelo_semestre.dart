//import 'package:cloud_firestore/cloud_firestore.dart'; // Importar por si acaso se usara Timestamp

class Semestre {
  final String idSemestre; // Corresponds to Firestore document ID
  final String nombreSemestre; // Corresponds to 'nombre_semestre' field
  final bool activo;

  Semestre({
    required this.idSemestre,
    required this.nombreSemestre,
    this.activo = true,
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
