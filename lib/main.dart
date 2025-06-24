import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:login_app/firebase_options.dart';
import 'package:login_app/login_app/login_screen.dart';
import 'package:login_app/login_app/registration_screen.dart';
import 'package:login_app/login_app/main_menu_screen.dart';
import 'package:login_app/components/pages.dart';
import 'package:login_app/pestañas/infoacade.dart' as pages;
import 'package:login_app/navMethods/servicio_residencias_navigation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:login_app/reinscripcion.dart' as reinscripcion;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InscribeTEC',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''), // Spanish
        Locale('en', ''), // English
        Locale('es', 'MX'), // Mexican Spanish
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      home: const LoginScreen(),
      routes: {
        '/register': (context) => const RegistrationScreen(),
        '/main_menu': (context) => const MainMenuScreen(),
        '/one': (context) => const PageOne(),
        '/two': (context) => const pages.AcademicInfo(),
        '/three': (context) => const reinscripcion.PageThree(),
        '/four': (context) => const ServicioResidenciasNavigation(),
      },
    );
  }
}
