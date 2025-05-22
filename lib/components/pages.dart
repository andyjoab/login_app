// lib/components/pages.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para TextInputFormatter
import 'package:intl/intl.dart'; // Necesario para DateFormat

class PageOne extends StatefulWidget {
  // <--- Importante: Cambiamos a StatefulWidget
  const PageOne({super.key});

  @override
  State<PageOne> createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {
  final _formKey = GlobalKey<FormState>(); // Clave global para el formulario

  // Controladores para todos los campos del formulario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController =
      TextEditingController(); // Un solo campo para apellido(s) si así lo deseas
  final TextEditingController _curpController = TextEditingController();
  final TextEditingController _fechaNacimientoController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _entidadController = TextEditingController();
  final TextEditingController _municipioController = TextEditingController();
  final TextEditingController _coloniaController = TextEditingController();
  final TextEditingController _calleController = TextEditingController();

  // Función para seleccionar fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale(
        'es',
        'ES',
      ), // Para que el selector de fecha esté en español
    );
    if (picked != null) {
      setState(() {
        _fechaNacimientoController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(picked); // Formato DD/MM/AAAA
      });
    }
  }

  @override
  void dispose() {
    // Es crucial liberar los controladores cuando el widget se destruye
    _nombreController.dispose();
    _apellidoController.dispose();
    _curpController.dispose();
    _fechaNacimientoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _entidadController.dispose();
    _municipioController.dispose();
    _coloniaController.dispose();
    _calleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Información Personal',
          style: TextStyle(
            color: Colors.black, // Color del título
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white, // Fondo del AppBar
        elevation: 0, // Elimina la sombra
        iconTheme: const IconThemeData(
          color: Colors.blue,
        ), // Color de la flecha de retroceso
        // La flecha de retroceso (leading) aparecerá automáticamente si esta pantalla
        // es empujada sobre el stack de navegación (ej. con Navigator.push)
      ),
      body: SingleChildScrollView(
        // Permite hacer scroll si el contenido es grande
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Nombre
              _buildTextFormField(
                controller: _nombreController,
                labelText: 'Nombre(s)',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
                    return 'Solo letras y espacios';
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),

              // Apellido (puedes unificar paterno/materno o separarlos si prefieres)
              _buildTextFormField(
                controller: _apellidoController,
                labelText: 'Apellido(s)',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
                    return 'Solo letras y espacios';
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),

              // CURP
              _buildTextFormField(
                controller: _curpController,
                labelText: 'CURP',
                icon: Icons.badge,
                maxLength: 18,
                textCapitalization:
                    TextCapitalization.characters, // Convierte a mayúsculas
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (value.length != 18) {
                    return 'La CURP debe tener 18 caracteres';
                  }
                  // Validación de formato de CURP (básica)
                  if (!RegExp(
                    r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[0-9A-Z]{2}$',
                  ).hasMatch(value)) {
                    return 'Formato CURP inválido';
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z0-9]'),
                  ), // Solo letras y números
                ],
              ),
              const SizedBox(height: 20),

              // Fecha de Nacimiento
              _buildTextFormField(
                controller: _fechaNacimientoController,
                labelText: 'Fecha de Nacimiento (DD/MM/AAAA)',
                icon: Icons.calendar_today,
                readOnly: true, // Para que el teclado no aparezca
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  // Validación básica de formato DD/MM/AAAA
                  if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                    return 'Formato DD/MM/AAAA inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email
              _buildTextFormField(
                controller: _emailController,
                labelText: 'Correo Electrónico',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Teléfono
              _buildTextFormField(
                controller: _telefonoController,
                labelText: 'Teléfono (10 dígitos)',
                icon: Icons.phone,
                maxLength: 10,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ], // Solo números
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (value.length != 10) {
                    return 'El teléfono debe tener 10 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Entidad (Estado)
              _buildTextFormField(
                controller: _entidadController,
                labelText: 'Entidad Federativa',
                icon: Icons.map,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
                    return 'Solo letras y espacios';
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),

              // Municipio
              _buildTextFormField(
                controller: _municipioController,
                labelText: 'Municipio',
                icon: Icons.location_city,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
                    return 'Solo letras y espacios';
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),

              // Colonia
              _buildTextFormField(
                controller: _coloniaController,
                labelText: 'Colonia',
                icon: Icons.landscape,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  return null;
                },
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),

              // Calle
              _buildTextFormField(
                controller: _calleController,
                labelText: 'Calle y Número',
                icon: Icons.home,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  return null;
                },
                keyboardType: TextInputType.streetAddress,
              ),
              const SizedBox(height: 30),

              // Botón de Guardar
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Si el formulario es válido, puedes procesar los datos
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Información personal guardada!'),
                        ),
                      );
                      _printFormData(); // Imprime los datos en la consola para depuración
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Por favor, corrige los errores en el formulario.',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Guardar Información',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Espacio al final del scroll
            ],
          ),
        ),
      ),
    );
  }

  // --- Funciones auxiliares para construir campos de texto ---
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
    );
  }

  // Función para imprimir los datos del formulario (para depuración)
  void _printFormData() {
    debugPrint('--- Datos del Formulario de Información Personal ---');
    debugPrint('Nombre(s): ${_nombreController.text}');
    debugPrint('Apellido(s): ${_apellidoController.text}');
    debugPrint('CURP: ${_curpController.text}');
    debugPrint('Fecha de Nacimiento: ${_fechaNacimientoController.text}');
    debugPrint('Correo Electrónico: ${_emailController.text}');
    debugPrint('Teléfono: ${_telefonoController.text}');
    debugPrint('Entidad: ${_entidadController.text}');
    debugPrint('Municipio: ${_municipioController.text}');
    debugPrint('Colonia: ${_coloniaController.text}');
    debugPrint('Calle: ${_calleController.text}');
    debugPrint('--------------------------------------------------');
  }
}

// Las demás clases (AcademicInfo, PageThree, PageFour) permanecen igual
// Asegúrate de que tu AcademicInfo esté en infoacade.dart y se importe correctamente
// donde sea usada, y elimina o comenta la clase AcademicInfo de este archivo.
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
      body: const Center(child: Text('Reinscripcion')),
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
