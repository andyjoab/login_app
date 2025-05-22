import 'package:flutter/material.dart';
//import 'package:login_app/login_app/registration_screen.dart';
//import 'main_menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Aquí iría tu lógica de autenticación real
      // Por ahora, simulamos un login exitoso
      // ignore: avoid_print
      print(
        'Correo: ${_emailController.text}, Contraseña: ${_passwordController.text}',
      );
      Navigator.pushReplacementNamed(context, '/main_menu');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            top:
                MediaQuery.of(context).padding.top +
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
                        67,
                        186,
                        241,
                      // ignore: deprecated_member_use
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
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 40.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    /* Image.asset(
                      'assets/logo_login_tecnm.png',
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 40.0),
*/
                    // Campo de Correo Electrónico
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration.copyWith(
                        labelText: 'Correo Institucional (alumno@test.edu.mx)',
                        prefixIcon: const Icon(Icons.email, color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa tu correo institucional';
                        }
                        // Validación de correo institucional
                        // Se verifica que termine en .edu.mx o .edu.mx, y que tenga el formato básico
                        if (!RegExp(
                          r'^[a-zA-Z0-9._%+-]+@(?:[a-zA-Z0-9-]+\.)+(edu\.mx|tecnm\.mx)$',
                        ).hasMatch(value)) {
                          return 'Ingresa un correo institucional válido (ej. alumno@test.edu.mx)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),

                    // Campo de Contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputDecoration.copyWith(
                        labelText: 'Contraseña (9 dígitos)',
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa tu contraseña';
                        }
                        if (value.length != 9) {
                          return 'La contraseña debe tener 9 dígitos';
                        }
                        // Opcional: Si quieres que solo sean números, la expresión regular anterior ya lo valida
                        // Si puede contener letras y números, puedes usar: !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)
                        // Dejamos la validación anterior que solo permite números si ese es el requerimiento.
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'La contraseña debe contener solo números';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30.0),

                    // Botón de Iniciar Sesión con degradado
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
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),

                    // Botón de Registrarse (TextButton estilizado)
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueAccent,
                        textStyle: const TextStyle(
                          fontSize: 16.0,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      child: const Text('¿Aún no tienes cuenta? Regístrate'),
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
