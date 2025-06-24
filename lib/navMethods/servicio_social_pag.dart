import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io'; // Necesario para 'File' en plataformas no web
import 'dart:typed_data'; // Necesario para 'Uint8List' en web
import 'package:flutter/foundation.dart'
    show kIsWeb; // Para detectar si estamos en la web

import 'package:login_app/modelos/modelo_carga_documentos.dart';
import 'package:url_launcher/url_launcher.dart';

class ServicioSocialPage extends StatelessWidget {
  const ServicioSocialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServicioSocialScreen();
  }
}

class ServicioSocialScreen extends StatefulWidget {
  const ServicioSocialScreen({super.key});

  @override
  State<ServicioSocialScreen> createState() => _ServicioSocialScreenState();
}

class _ServicioSocialScreenState extends State<ServicioSocialScreen> {
  final Map<String, DocumentoSubido?> _uploadedDocuments = {};

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> _requiredDocuments = [
    'Hoja de autorización de SENSISER pdf',
    'Carnet de salud vigente',
    'Constancia 4 nivel idioma inglés',
    'Constancia académica',
  ];

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      _loadUploadedDocuments();
    });
    _loadUploadedDocuments();
  }

  Future<void> _loadUploadedDocuments() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _uploadedDocuments.clear();
      });
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('alumnos')
          .doc(user.uid)
          .collection('documentos_servicio_social')
          .get();

      setState(() {
        _uploadedDocuments.clear();
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
      String fileName = result.files.single.name;
      String filePath =
          'alumnos/${user.uid}/documentos_servicio_social/$fileName';

      try {
        _showSnackBar('Subiendo $documentType...');

        UploadTask uploadTask;

        if (kIsWeb) {
          // Para la web, usamos putData con los bytes del archivo
          if (result.files.single.bytes == null) {
            _showSnackBar(
                'Error: No se pudo obtener el contenido del archivo en la web.');
            return;
          }
          Uint8List fileBytes = result.files.single.bytes!;
          uploadTask = _storage.ref().child(filePath).putData(fileBytes);
        } else {
          // Para móvil/escritorio, usamos putFile con la ruta del archivo
          if (result.files.single.path == null) {
            _showSnackBar('Error: No se pudo obtener la ruta del archivo.');
            return;
          }
          File file = File(result.files.single.path!);
          uploadTask = _storage.ref().child(filePath).putFile(file);
        }

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        await _firestore
            .collection('alumnos')
            .doc(user.uid)
            .collection('documentos_servicio_social')
            .doc(documentType)
            .set(DocumentoSubido(
                    tipoDocumento: documentType,
                    url: downloadUrl,
                    fechaSubida: Timestamp.now(),
                    nombreArchivo: fileName)
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
      } on FirebaseException catch (e) {
        _showSnackBar('Error al subir $documentType: ${e.message}');
        debugPrint('Error de Firebase: $e');
      } catch (e) {
        _showSnackBar('Error desconocido al subir $documentType: $e');
        debugPrint('Error general: $e');
      }
    } else {
      _showSnackBar('Selección de archivo cancelada.');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _viewPdf(String url) async {
    if (url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          _showSnackBar('No se pudo abrir el enlace: $url');
          debugPrint('No se pudo lanzar URL: $url');
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
        title: const Text('Servicio Social',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _auth.currentUser == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Inicia sesión para subir y gestionar tus documentos de Servicio Social.',
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
              offset: const Offset(0, 2),
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
              if (isUploaded)
                IconButton(
                  icon: const Icon(Icons.visibility,
                      color: Colors.grey, size: 28),
                  onPressed: () {
                    if (uploadedDoc!.url.isNotEmpty) {
                      _viewPdf(uploadedDoc.url);
                    }
                  },
                  tooltip: 'Ver documento subido',
                ),
              IconButton(
                icon: Icon(
                  isUploaded ? Icons.cloud_upload : Icons.note_add,
                  color: isUploaded ? Colors.orange : Colors.blue,
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
