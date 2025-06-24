import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar Firebase Auth
import 'dart:io';

// Importar el modelo de documento subido
import 'package:login_app/modelos/modelo_carga_documentos.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir URLs

class ResidenciasPage extends StatelessWidget {
  const ResidenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessionalResidencyScreen();
  }
}

class ProfessionalResidencyScreen extends StatefulWidget {
  const ProfessionalResidencyScreen({super.key});

  @override
  State<ProfessionalResidencyScreen> createState() =>
      _ProfessionalResidencyScreenState();
}

class _ProfessionalResidencyScreenState
    extends State<ProfessionalResidencyScreen> {
  // Mapa para guardar las URLs y el estado de los documentos subidos
  // Mapea el tipo de documento (String) a un objeto DocumentoSubido (o null si no está subido)
  final Map<String, DocumentoSubido?> _uploadedDocuments = {};

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Instancia de Firebase Auth

  // Lista de tipos de documentos requeridos para Residencias
  final List<String> _requiredDocuments = [
    'Hoja de autorización sellado por la institución',
    'Carnet de salud vigente',
    'Constancia de acreditación del idioma inglés',
    'Carta de termino de Servicio Social',
    'Constancia academica',
  ];

  @override
  void initState() {
    super.initState();
    _loadUploadedDocuments();
  }

  // Cargar documentos subidos desde Firestore
  Future<void> _loadUploadedDocuments() async {
    final user = _auth.currentUser;
    if (user == null) {
      // Si no hay usuario autenticado, no hay documentos que cargar
      setState(() {
        _uploadedDocuments.clear();
      });
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('alumnos')
          .doc(user.uid)
          .collection(
              'documentos_subidos') // Colección específica para residencias
          .get();

      setState(() {
        _uploadedDocuments.clear(); // Limpiar antes de recargar
        for (var doc in snapshot.docs) {
          final documento = DocumentoSubido.fromFirestore(doc);
          _uploadedDocuments[documento.tipoDocumento] = documento;
        }
      });
    } catch (e) {
      _showSnackBar('Error al cargar documentos: $e');
      debugPrint('Error al cargar documentos: $e');
    }
  }

  // Función para seleccionar y subir un PDF a Firebase Storage
  Future<void> _pickAndUploadPdf(String documentType) async {
    final user = _auth.currentUser;
    if (user == null) {
      _showSnackBar('Debes iniciar sesión para subir documentos.');
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      try {
        _showSnackBar('Subiendo $documentType...');

        // ruta  alumnos/{UID}/documentos_subidos/{nombre_archivo.pdf}
        String filePath = 'alumnos/${user.uid}/documentos_subidos/$fileName';

        UploadTask uploadTask = _storage.ref().child(filePath).putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Guardar metadatos en Firestore
        await _firestore
            .collection('alumnos')
            .doc(user.uid)
            .collection('documentos_subidos') // Colección específica
            .doc(
                documentType) // Usamos el tipo de documento como ID del documento
            .set(DocumentoSubido(
                    tipoDocumento: documentType,
                    url: downloadUrl,
                    fechaSubida: Timestamp.now(),
                    nombreArchivo:
                        fileName) // Guardamos el nombre original del archivo
                .toFirestore());

        setState(() {
          _uploadedDocuments[documentType] = DocumentoSubido(
            tipoDocumento: documentType,
            url: downloadUrl,
            fechaSubida: Timestamp.now(),
            nombreArchivo: fileName,
          );
        });

        _showSnackBar('$documentType subido exitosamente.');
        _loadUploadedDocuments(); // Recargar el estado después de la subida
      } on FirebaseException catch (e) {
        _showSnackBar('Error al subir $documentType: ${e.message}');
        debugPrint('Error de Firebase: $e');
      } catch (e) {
        _showSnackBar('Error desconocido al subir $documentType: $e');
        debugPrint('Error general: $e');
      }
    } else {
      // El usuario canceló la selección
      _showSnackBar('Selección de archivo cancelada.');
    }
  }

  // Función para mostrar SnackBar
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  // Función para abrir la URL de un PDF (simulada o real con url_launcher)
  Future<void> _viewPdf(String url) async {
    if (url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          _showSnackBar('No se pudo abrir el enlace: $url');
        }
      } catch (e) {
        _showSnackBar('Error al abrir el documento: $e');
        debugPrint('Error al abrir URL: $e');
      }
    } else {
      _showSnackBar('La URL del documento no es válida.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text('Residencia Profesional',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700], // Un azul más oscuro para el AppBar
        iconTheme: const IconThemeData(
            color: Colors.white), // Color del icono de retroceso
      ),
      body: _auth.currentUser == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Inicia sesión para subir y gestionar tus documentos de Residencia Profesional.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _requiredDocuments.length,
              itemBuilder: (context, index) {
                final documentType = _requiredDocuments[index];
                final uploadedDoc = _uploadedDocuments[documentType];
                final bool isUploaded = uploadedDoc != null;

                return _buildDocumentUploadTile(
                    documentType, isUploaded, uploadedDoc);
              },
            ),
    );
  }

  // Widget para construir cada fila de documento para subir
  Widget _buildDocumentUploadTile(
      String documentType, bool isUploaded, DocumentoSubido? uploadedDoc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          title: Text(
            documentType,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: isUploaded
              ? Text(
                  'Subido: ${uploadedDoc!.nombreArchivo ?? 'documento.pdf'} el ${uploadedDoc.fechaSubida.toDate().day}/${uploadedDoc.fechaSubida.toDate().month}/${uploadedDoc.fechaSubida.toDate().year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
              : const Text(
                  'No subido',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isUploaded) // Solo mostrar el botón de ver si ya hay un documento subido
                IconButton(
                  icon: const Icon(Icons.visibility,
                      color: Colors.grey, size: 28),
                  onPressed: () {
                    if (uploadedDoc!.url.isNotEmpty) {
                      _viewPdf(
                          uploadedDoc.url); // Llama a la función para ver PDF
                    }
                  },
                  tooltip: 'Ver documento subido',
                ),
              IconButton(
                // Ícono de carga/re-carga
                icon: Icon(
                  isUploaded
                      ? Icons
                          .cloud_upload // Icono de nube si ya está subido (reemplazar)
                      : Icons.note_add, // Si no, icono de añadir nota
                  color: isUploaded
                      ? Colors
                          .orange // Naranja si ya está subido (para indicar que se puede reemplazar)
                      : Colors.blue, // Azul para subir
                  size: 30,
                ),
                onPressed: () => _pickAndUploadPdf(documentType),
                tooltip:
                    isUploaded ? 'Reemplazar documento' : 'Subir documento',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
