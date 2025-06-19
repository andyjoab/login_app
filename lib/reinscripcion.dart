import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart'; // Import Firebase
//import 'package:login_app/firebase_options.dart'; // Assuming you have this file for Firebase options
import 'package:login_app/reinscripcion/semestre.dart'; // New screen

//void main() async {
//WidgetsFlutterBinding.ensureInitialized();
//await Firebase.initializeApp(
//options: DefaultFirebaseOptions.currentPlatform, // Initialize Firebase
//);
//}

class PageThree extends StatelessWidget {
  const PageThree({super.key});

  @override
  Widget build(BuildContext context) {
    /* return MaterialApp(
      title: 'InscribeTEC', // Or 'Reinscripción' as per your screenshot
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ), // Adjust your primary color
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      home:
          const Seleccionsemestre(), // Start with the semester selection screen
      // Define routes if you plan to use named routes for navigation
      routes: {
        '/semesterSelection': (context) => const Seleccionsemestre(),
        // Add other routes as you create more screens
      },
    );
  }
}*/
    return Scaffold(
      // Envuelve tu contenido en un Scaffold
      appBar: AppBar(
        title: const Text('Reinscripción'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body:
          const Seleccionsemestre(), // Tu pantalla inicial de selección de semestre
    );
  }
}
