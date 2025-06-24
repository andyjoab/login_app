import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentoSubido {
  final String tipoDocumento;
  final String url;
  final Timestamp fechaSubida;
  final String? idFirebase;
  final String? nombreArchivo;
  final String? estado;

  DocumentoSubido({
    this.idFirebase,
    required this.tipoDocumento,
    required this.url,
    required this.fechaSubida,
    this.nombreArchivo, // Actualizar constructor
    this.estado,
  });

  factory DocumentoSubido.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DocumentoSubido(
      idFirebase: doc.id,
      tipoDocumento: data['tipo_documento'] ?? '',
      url: data['url'] ?? '',
      fechaSubida: data['fecha_subida'] as Timestamp,
      nombreArchivo: data['nombre_archivo'] ?? '', // Leer del mapa
      estado: data['estado'] ?? '', // Leer del mapa
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tipo_documento': tipoDocumento,
      'url': url,
      'fecha_subida': fechaSubida,
      'nombre_archivo': nombreArchivo, // Escribir en el mapa
      'estado': estado, // Escribir en el mapa
    };
  }
}
