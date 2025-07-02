import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // Importa esto para TextInputFormatter

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _errorMessage;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text == _confirmPasswordController.text) {
        try {
          UserCredential userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Registro exitoso!')),
          );
          Navigator.pop(context); // Vuelve a la pantalla de login
        } on FirebaseAuthException catch (e) {
          String message;
          if (e.code == 'email-already-in-use') {
            message =
                'El correo electrónico ya existe, por favor, intenta con otro.';
          } else if (e.code == 'weak-password') {
            message =
                'La contraseña es demasiado débil. Debe tener al menos 6 caracteres.';
          } else {
            message = 'Error desconocido: ${e.message}';
          }
          setState(() {
            _errorMessage = message;
          });
          debugPrint('Error de registro: $message');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos el ancho deseado para los campos y el botón
    final double desiredWidth = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor:
          Colors.white, // El color de fondo del Scaffold puede ser blanco
      appBar: AppBar(
        title: const Text(
          'Registro',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          // Imagen de fondo que cubre toda la pantalla
          Positioned.fill(
            child: Opacity(
              opacity: 1.0,
              child: Image.asset(
                'assets/Recurso 35.png', // Asegúrate que esta ruta y el pubspec.yaml sean correctos
                fit: BoxFit
                    .contain, // CAMBIO: Para mantener la forma y centrar la imagen
              ),
            ),
          ),
          // TEXTO DEL TÍTULO SUPERIOR (si lo quieres visible)
          /*
          Positioned(
            top: MediaQuery.of(context).padding.top + 20.0,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '¡Regístrate!', // Ejemplo de texto
                style: TextStyle(
                  color: Color(0xFF1518C3),
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: const Color.fromARGB(255, 45, 105, 235).withOpacity(0.3),
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
          */
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Espacio para centrar el formulario si no hay un título arriba
                    const SizedBox(
                        height:
                            50.0), // Ajusta este valor si necesitas más o menos espacio

                    // Campo de Correo Electrónico
                    SizedBox(
                      width: desiredWidth, // Ancho consistente
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration.copyWith(
                          labelText: 'Correo Institucional @test.edu.mx',
                          prefixIcon: const Icon(Icons.email,
                              color: Colors.white), // CAMBIO: Icono blanco
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa tu correo institucional';
                          }
                          if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@(?:[a-zA-Z0-9-]+\.)+(edu\.mx|tecnm\.mx)$',
                          ).hasMatch(value)) {
                            return 'Ingresa un correo institucional válido (ej. alumno@test.edu.mx)';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Campo de Crear Contraseña
                    SizedBox(
                      width: desiredWidth, // Ancho consistente
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        keyboardType:
                            TextInputType.number, // Para teclado numérico
                        inputFormatters: [
                          // Para limitar a 9 dígitos
                          LengthLimitingTextInputFormatter(9),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _inputDecoration.copyWith(
                          labelText: 'Crea tu contraseña (9 dígitos)',
                          prefixIcon: const Icon(Icons.lock,
                              color: Colors.white), // CAMBIO: Icono blanco
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, crea una contraseña';
                          }
                          if (value.length != 9) {
                            return 'La contraseña debe tener 9 dígitos';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'La contraseña debe contener solo números';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Campo de Confirmar Contraseña
                    SizedBox(
                      width: desiredWidth, // Ancho consistente
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        keyboardType:
                            TextInputType.number, // Para teclado numérico
                        inputFormatters: [
                          // Para limitar a 9 dígitos
                          LengthLimitingTextInputFormatter(9),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _inputDecoration.copyWith(
                          labelText: 'Confirma tu contraseña',
                          prefixIcon: const Icon(Icons.lock_reset,
                              color: Colors.white), // CAMBIO: Icono blanco
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, confirma tu contraseña';
                          }
                          if (value.length != 9) {
                            return 'La contraseña debe tener 9 dígitos';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'La contraseña debe contener solo números';
                          }
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30.0),

                    // Botón de Registrarse con degradado
                    SizedBox(
                      // Envolviendo el Container con SizedBox para el ancho
                      width: desiredWidth, // Ancho consistente
                      child: Container(
                        height: 50.0,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFAEF359),
                              Color(0xFFB0FC38),
                              Color(0xFF3CB043),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(50, 50),
                            backgroundColor: Colors.transparent,
                            shadowColor: const Color.fromRGBO(0, 0, 0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Registrarse',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Estilo común para los InputDecoration de los TextFormField
  InputDecoration get _inputDecoration => InputDecoration(
        filled: true, // CAMBIO: Habilitado para tener un color de relleno
        fillColor: Colors.white.withOpacity(
            0.2), // CAMBIO: Color de relleno blanco semi-transparente
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 15.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
              color: Colors.white, width: 1.0), // CAMBIO: Borde blanco
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
              color: Colors.white, width: 1.0), // CAMBIO: Borde blanco
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 100, 226, 16),
              width: 2.0), // CAMBIO: Color de foco más claro
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 25, 179, 11), width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        labelStyle:
            const TextStyle(color: Colors.white), // CAMBIO: Etiqueta en blanco
        hintStyle: const TextStyle(
            color: Colors
                .white70), // CAMBIO: Sugerencia en blanco semi-transparente
      );
}
