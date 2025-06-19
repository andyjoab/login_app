// lib/components/pages.dart
import 'package:flutter/material.dart';
// No necesitas todas estas importaciones si solo vas a usar InfoPersonalScreen
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // No necesaria aquí si pasas el UID
// import 'package:login_app/modelos/modelo_alumno.dart';
// import 'package:login_app/firebase_options.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:login_app/reinscripcion/semestre.dart'; // Asegúrate de que este archivo exista
import 'package:login_app/navMethods/registro_alumno.dart'; // Importa InfoPersonalScreen
import 'package:firebase_auth/firebase_auth.dart'; // Necesario para obtener el UID aquí

class PageOne extends StatefulWidget {
  const PageOne({super.key});

  @override
  State<PageOne> createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {
  String? _userUid;

  @override
  void initState() {
    super.initState();
    _getUserUid();
  }

  void _getUserUid() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userUid = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userUid == null) {
      // mensaje si el UID aún no está disponible
      return const Center(child: CircularProgressIndicator());
    }

    return InfoPersonalScreen(userUid: _userUid!); // Usa InfoPersonalScreen
  }
}

/*
class AcademicInfo extends StatelessWidget {
  const AcademicInfo({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información academica'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(child: Text('')),
    );
  }
}
*/

class PageThree extends StatelessWidget {
  const PageThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reinscripción',
          style: TextStyle(color: Color.fromARGB(255, 243, 152, 33)),
        ),
        backgroundColor: const Color.fromARGB(255, 123, 121, 128),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navega a la pantalla de selección de semestre
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const Seleccionsemestre()),
            );
          },
          child: const Text('Ir a Reinscripción'),
        ),
      ),
    );
  }
}

class PageFour extends StatelessWidget {
  const PageFour({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicio social/Residencias'),
        backgroundColor: const Color.fromARGB(255, 224, 94, 55),
      ),
      body: const Center(child: Text('Servicio social/Residencias')),
    );
  }
}
