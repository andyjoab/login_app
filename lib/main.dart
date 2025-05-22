import 'package:flutter/material.dart';
// import 'login_screen.dart';
import 'package:login_app/login_app/login_screen.dart';
import 'package:login_app/login_app/registration_screen.dart';
import 'package:login_app/login_app/main_menu_screen.dart';
import 'package:login_app/components/pages.dart';
import 'package:login_app/pestañas/infoacade.dart'
    as pages; 
import 'package:login_app/navMethods/servicio_residencias_navigation.dart'; 

void main() {
  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InscribeTEC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      home: const LoginScreen(), 
      routes: {
        '/register': (context) => const RegistrationScreen(), 
        '/main_menu': (context) => const MainMenuScreen(), 
        '/one': (context) => const PageOne(),
        '/two': (context) => const pages.AcademicInfo(),
        '/three': (context) => const PageThree(),
        '/four':
            (context) =>
                const ServicioResidenciasNavigation(), 
      },
    );
  }
}
