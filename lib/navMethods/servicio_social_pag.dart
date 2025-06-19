import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Opcional: para guardar metadatos en Firestore
import 'dart:io';

import 'package:login_app/login_app/main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      // Reemplaza estos valores con tu configuración de Firebase
      apiKey: "TU_API_KEY",
      authDomain: "TU_AUTH_DOMAIN",
      projectId: "TU_PROJECT_ID",
      storageBucket: "TU_STORAGE_BUCKET",
      messagingSenderId: "TU_MESSAGING_SENDER_ID",
      appId: "TU_APP_ID",
    ),
  );
}

class ServicioSocialPage extends StatelessWidget {
  const ServicioSocialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ServicioSocialScreen();
  }
}

class ServicioSocialScreen extends StatefulWidget {
  const ServicioSocialScreen({super.key});

  @override
  State<ServicioSocialScreen> createState() => _ServicioSocialScreenState();
}

class _ServicioSocialScreenState extends State<ServicioSocialScreen> {
  // Mapa para guardar la URL del archivo subido para cada tipo de documento
  // Esto simula cómo podrías mantener el estado de los documentos ya subidos
  final Map<String, String?> _uploadedFileUrls = {
    'Hoja de autorización de SENSISER(PDF)': null,
    'Carnet de salud vigente': null,
    'Constancia 4 nivel del idioma inglés': null,
    'Constancia académica': null,
  };

  // Referencia a Firebase Storage
  final FirebaseStorage _storage = FirebaseStorage.instance;
  // Opcional: Referencia a Cloud Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función para seleccionar y subir un archivo PDF
  Future<void> _pickAndUploadPdf(String documentType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
        Reference ref =
            _storage.ref().child('servicio_social/$documentType/$fileName');

        // Mostrar un indicador de carga
        _showMessageBox(context, 'Subiendo archivo...', false);

        UploadTask uploadTask = ref.putFile(file);

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          // Puedes usar esto para mostrar el progreso de la carga
          double progress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          print('Progreso de carga: $progress%');
        });

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _uploadedFileUrls[documentType] = downloadUrl;
        });

        // Cerrar el indicador de carga y mostrar mensaje de éxito
        Navigator.pop(context); // Cierra el mensaje de carga
        _showMessageBox(context,
            'Archivo subido exitosamente: ${result.files.single.name}', true);

        // Opcional: Guardar la URL del archivo en Cloud Firestore
        await _firestore
            .collection('user_documents')
            .doc('current_user_id')
            .set({
          documentType: downloadUrl,
          'last_updated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)); // Merge para no sobrescribir otros campos
        print('URL guardada en Firestore: $downloadUrl');
      } else {
        // El usuario canceló la selección
        _showMessageBox(context, 'Selección de archivo cancelada.', true);
      }
    } catch (e) {
      // Manejo de errores durante la selección o carga
      print('Error al seleccionar o subir archivo: $e');
      Navigator.pop(
          context); // Asegurarse de cerrar el mensaje de carga en caso de error
      _showMessageBox(context, 'Error al subir el archivo: $e', true);
    }
  }

  // Función para mostrar un cuadro de mensaje personalizado (reemplazo de alert())
  void _showMessageBox(BuildContext context, String message, bool dismissible) {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text('Notificación'),
          content: Text(message),
          actions: <Widget>[
            if (dismissible)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
                child: Text('Aceptar'),
                onPressed: () {
                  Navigator.of(dialogContext)
                      .pop(); // Cierra el cuadro de diálogo
                },
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Servicio Social'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Regresa a la pantalla anterior
              // Navega hacia atrás
            },
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Por favor sube los siguientes documentos de manera individual, en formato pdf',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _uploadedFileUrls.keys.map((documentType) {
                  return _buildDocumentUploadTile(documentType);
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para guardar todos los cambios o enviar la información
                  // En una aplicación real, aquí podrías enviar todas las URLs
                  // de los documentos a un backend o a Firestore.
                  _showMessageBox(
                      context, 'Documentos guardados (simulado).', true);
                  print('URLs de documentos subidos: $_uploadedFileUrls');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 255, 255, 255), // Color de fondo del botón
                  foregroundColor: Colors.white, // Color del texto
                  minimumSize:
                      Size(double.infinity, 50), // Ancho completo, altura fija
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Esquinas redondeadas
                  ),
                  elevation: 5, // Sombra
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir cada fila de documento para subir
  Widget _buildDocumentUploadTile(String documentType) {
    final bool isUploaded = _uploadedFileUrls[documentType] != null;
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
              offset: Offset(0, 2), // changes position of shadow
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
          trailing: IconButton(
            icon: Icon(
              isUploaded
                  ? Icons.check_circle
                  : Icons.note_add, // Icono de verificación si ya se subió
              color: isUploaded ? Colors.green : Colors.blue,
              size: 30,
            ),
            onPressed: () => _pickAndUploadPdf(documentType),
            tooltip: 'Subir archivo PDF para $documentType',
          ),
        ),
      ),
    );
  }
}
