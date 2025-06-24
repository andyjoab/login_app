import 'package:flutter/material.dart';
import 'package:login_app/reinscripcion/semestre.dart';

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
      appBar: AppBar(
        title: const Text('Reinscripción'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        iconTheme: IconThemeData(
          color: Color.fromARGB(255, 39, 38, 38),
        ),
        foregroundColor: Colors.black,
      ),
      body: const Seleccionsemestre(),
    );
  }
}
