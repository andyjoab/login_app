import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ¡Importa esto!
import 'package:firebase_auth/firebase_auth.dart';

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

  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);

    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        print(
            'Correo: ${_emailController.text}, Contraseña: ${_passwordController.text}');
        Navigator.pushReplacementNamed(context, '/main_menu');
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message =
              'No se encontró ningún usuario para ese correo institucional.';
        } else if (e.code == 'wrong-password') {
          message = 'Contraseña incorrecta.';
        } else {
          message = 'Error al iniciar sesión: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print(message);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocurrió un error inesperado: $e')),
        );
        print('Error general: $e');
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onFocusChange);
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color _getEmailFieldFillColor() {
      if (_emailFocusNode.hasFocus || _emailController.text.isNotEmpty) {
        return Colors.white.withOpacity(0.3);
      }
      return Colors.transparent;
    }

    Color _getPasswordFieldFillColor() {
      if (_passwordFocusNode.hasFocus || _passwordController.text.isNotEmpty) {
        return Colors.white.withOpacity(0.3);
      }
      return Colors.transparent;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 1.0,
              child: Image.asset(
                'assets/Recurso 80.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 20.0,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '', //texto pedniente
                style: TextStyle(
                  color: Color(0xFF03C04A),
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: const Color.fromARGB(
                        255,
                        67,
                        186,
                        241,
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                    // Campo de Correo Electrónico
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Container(
                        // CAMBIO: Envuelto en Container para la sombra
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                  0.2), // Color y opacidad de la sombra
                              spreadRadius: 2,
                              blurRadius: 7,
                              offset: const Offset(
                                  0, 3), // Desplazamiento de la sombra
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            labelText: 'Correo Institucional @test.edu.mx',
                            prefixIcon: Icons.email,
                            fillColor: _getEmailFieldFillColor(),
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
                    ),
                    const SizedBox(height: 20.0),

                    // Campo de Contraseña
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Container(
                        // CAMBIO: Envuelto en Container para la sombra
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: true,
                          keyboardType:
                              TextInputType.number, // Abre el teclado numérico
                          inputFormatters: [
                            // Restringe la entrada
                            LengthLimitingTextInputFormatter(
                                9), // Limita a 9 caracteres
                            FilteringTextInputFormatter
                                .digitsOnly, // Solo permite dígitos
                          ],
                          decoration: _inputDecoration(
                            labelText: 'Contraseña (9 dígitos)',
                            prefixIcon: Icons.lock,
                            fillColor: _getPasswordFieldFillColor(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa tu contraseña';
                            }
                            // Con los formatters, estas validaciones de longitud y solo números son redundantes en tiempo real,
                            // pero se mantienen para casos como pegar texto o como una doble verificación.
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
                    ),
                    const SizedBox(height: 30.0),

                    // Botón de Iniciar Sesión con degradado
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 45.0,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFAEF359),
                            Color(0xFF3CB043),
                            Color(0xFFB0FC38),
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
                          'Inicia sesión',
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
                        foregroundColor: const Color(0xFF388697),
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
  InputDecoration _inputDecoration({
    required String labelText,
    required IconData prefixIcon,
    required Color fillColor,
  }) {
    // Determina si se deben usar colores claros para el texto/iconos
    // Esto se basa en si el campo tiene un color de relleno (no es completamente transparente)
    bool useLightColors = fillColor != Colors.transparent;

    return InputDecoration(
      filled: fillColor != Colors.transparent,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 15.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
            color: useLightColors ? Colors.white : Colors.grey, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
            color: useLightColors ? Colors.white : Colors.grey, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
            color: Color(0xFF3CB043),
            width: 2.0), // CAMBIO: Borde de enfoque verde
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      labelStyle: TextStyle(
          color: useLightColors
              ? Colors.white
              : Colors.black54), // CAMBIO: Color de etiqueta dinámico
      hintStyle: TextStyle(
          color: useLightColors
              ? Colors.white70
              : Colors.green), // CAMBIO: Color de sugerencia dinámico
      prefixIcon: Icon(prefixIcon,
          color: useLightColors
              ? Colors.white
              : Colors.green), // CAMBIO: Color de icono dinámico
      labelText: labelText,
    );
  }
}
