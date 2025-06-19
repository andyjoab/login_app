// lib/models/modelo_grupo.dart (MODIFICADO - Añadido toFirestore)
//import 'package:cloud_firestore/cloud_firestore.dart'; // Importar si se usa Timestamp, aunque no sea el caso directo, es buena práctica.

class Grupo {
  final String idGrupo; // Firestore document ID
  final String nombreGrupo; // e.g., "G-A", "G-B"
  final String idSemestre; // e.g., "S1", "S3"
  final String nombreSemestre; // Añadido para redundancia útil en la UI

  Grupo({
    required this.idGrupo,
    required this.nombreGrupo,
    required this.idSemestre,
    required this.nombreSemestre,
  });

  factory Grupo.fromFirestore(Map<String, dynamic> data, String id) {
    return Grupo(
      idGrupo: id,
      nombreGrupo: data['nombre_grupo'] ?? '',
      idSemestre: data['id_semestre'] ?? '',
      nombreSemestre: data['nombre_semestre'] ?? '',
    );
  }

  // Método para convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre_grupo': nombreGrupo,
      'id_semestre': idSemestre,
      'nombre_semestre': nombreSemestre,
    };
  }
}
