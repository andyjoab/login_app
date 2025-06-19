import 'package:flutter/material.dart';
//import 'login_screen.dart'; // Asegúrate que esta ruta sea correcta
import 'package:firebase_auth/firebase_auth.dart';

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

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text == _confirmPasswordController.text) {
        try {
          UserCredential userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
          // Aquí iría tu lógica de registro real
          print(
              'Correo de registro: ${_emailController.text}, Contraseña: ${_passwordController.text}');
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('¡Registro exitoso!')));
          Navigator.pop(context); // Vuelve a la pantalla de login
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Registro',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF265073),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/logo_login_tecnm.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top +
                20.0, // Ajusta 20.0 para la separación deseada del top seguro
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'InscribeTEC',
                style: TextStyle(
                  color: Color(0xFF1518C3), // Color azul oscuro para el texto
                  fontSize: 36.0, // Tamaño de fuente grande
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: const Color.fromARGB(
                        255,
                        45,
                        105,
                        235,
                      ).withOpacity(0.3),
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    /*
                    Image.asset(
                      'assets/logo_login_tecnm.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 30.0),
*/
                    // Campo de Correo Electrónico
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration.copyWith(
                        labelText:
                            'Correo Institucional (ej. alumno@test.edu.mx)',
                        prefixIcon: const Icon(Icons.email, color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa tu correo institucional';
                        }
                        // Validación de correo institucional
                        if (!RegExp(
                          r'^[a-zA-Z0-9._%+-]+@(?:[a-zA-Z0-9-]+\.)+(edu\.mx|tecnm\.mx)$',
                        ).hasMatch(value)) {
                          return 'Ingresa un correo institucional válido (ej. alumno@test.edu.mx)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),

                    // Campo de Crear Contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputDecoration.copyWith(
                        labelText: 'Crear Contraseña (9 dígitos)',
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
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
                    const SizedBox(height: 20.0),

                    // Campo de Confirmar Contraseña
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: _inputDecoration.copyWith(
                        labelText: 'Confirmar Contraseña',
                        prefixIcon: const Icon(
                          Icons.lock_reset,
                          color: Colors.grey,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, confirma tu contraseña';
                        }
                        if (value.length != 9) {
                          // Aseguramos que también la confirmación sea de 9
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
                    const SizedBox(height: 30.0),

                    // Botón de Registrarse con degradado
                    Container(
                      width: double.infinity,
                      height: 50.0,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF265073),
                            Color(0xFF388697),
                            Color(0xFF8FD6E8),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
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
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 15.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Color(0xFF265073), width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        labelStyle: const TextStyle(color: Colors.black54),
        hintStyle: const TextStyle(color: Colors.grey),
      );
}
