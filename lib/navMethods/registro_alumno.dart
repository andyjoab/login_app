import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para TextInputFormatter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Para formatear la fescha
import 'package:login_app/modelos/modelo_alumno.dart'; 
import 'package:login_app/components/pages.dart'; 

class InfoPersonalScreen extends StatefulWidget {
  final String userUid;

  const InfoPersonalScreen({super.key, required this.userUid});

  @override
  State<InfoPersonalScreen> createState() => _InfoPersonalScreenState();
}

class _InfoPersonalScreenState extends State<InfoPersonalScreen> {
  final _formKey = GlobalKey<FormState>(); // Clave global para el formulario

  // Controladores para todos los campos del formulario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _curpController = TextEditingController();
  final TextEditingController _correoInstitucionalController =
      TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _entidadController = TextEditingController();
  final TextEditingController _coloniaController = TextEditingController();
  final TextEditingController _municipioController = TextEditingController();
  final TextEditingController _calleController = TextEditingController();

  DateTime? _selectedDate; // Variable para almacenar la fecha seleccionada
  final TextEditingController _fechaNacimientoController =
      TextEditingController(); // Controlador para la fecha de nacimiento
  @override
  void initState() {
    super.initState();
    // Opcional: Cargar datos existentes si el alumno ya tiene un registro
    _loadExistingAlumnoData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _matriculaController.dispose();
    _curpController.dispose();
    _correoInstitucionalController.dispose();
    _telefonoController.dispose();
    _entidadController.dispose();
    _municipioController.dispose();
    _coloniaController.dispose();
    _calleController.dispose();
    _fechaNacimientoController.dispose();
    super.dispose();
  }

  // Método para cargar datos existentes del alumno si ya los tiene
  Future<void> _loadExistingAlumnoData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('alumnos')
          .doc(widget.userUid)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        _nombreController.text = data['nombre'] ?? '';
        _apellidoController.text = data['apellido'] ?? '';
        _matriculaController.text = data['matricula'] ?? '';
        _curpController.text = data['curp'] ?? '';
        _correoInstitucionalController.text =
            data['correo_institucional'] ?? '';
        _telefonoController.text = data['telefono'] ?? '';
        _entidadController.text = data['entidad'] ?? '';
        _coloniaController.text = data['colonia'] ?? '';
        _municipioController.text = data['municipio'] ?? '';
        _calleController.text = data['calle'] ?? '';
        if (data['fecha_nacimiento'] is Timestamp) {
          _selectedDate = (data['fecha_nacimiento'] as Timestamp).toDate();
          _fechaNacimientoController.text =
              DateFormat('dd/MM/yyyy').format(_selectedDate!);
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error al cargar datos existentes del alumno: $e");
      // Muestra un mensaje de error al usuario si es necesario
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      helpText: 'Selecciona una fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fechaNacimientoController.text =
            DateFormat('dd/MM/yyyy').format(_selectedDate!);
      });
    }
  }

  Future<void> _guardarDatosAlumno() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor, selecciona tu fecha de nacimiento.')),
        );
        return;
      }

      final Alumno nuevoAlumno = Alumno(
        uid: widget.userUid, // Usa el UID del widget
        nombre: _nombreController.text,
        apellido: _apellidoController.text,
        matricula: _matriculaController.text,
        curp: _curpController.text,
        fechaNacimiento: _selectedDate!,
        correoInstitucional: _correoInstitucionalController.text,
        telefono: _telefonoController.text,
        entidad: _entidadController.text,
        colonia: _coloniaController.text,
        municipio: _municipioController.text,
        calle: _calleController.text,
      );

      try {
        await FirebaseFirestore.instance
            .collection('alumnos')
            .doc(widget.userUid) // Guarda con el UID del usuario
            .set(nuevoAlumno.toFirestore(), SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Datos de alumno guardados exitosamente.')),
        );
      } catch (e) {
        debugPrint("Error al guardar datos del alumno: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar datos: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrige los errores en el formulario.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Información Personal',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.blue,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTextFormField(
                _nombreController,
                'Nombre(s)',
                'Ingresa tu(s) nombre(s)',
                (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
                    return 'Solo letras y espacios';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                _apellidoController,
                'Apellido(s)',
                'Ingresa tus apellido(s)',
                (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
                    return 'Solo letras y espacios';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                _matriculaController,
                'Matrícula',
                'Ingresa tu matrícula (ej. 201234567)',
                (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Solo números';
                  }
                  if (value.length != 9) return 'Debe tener 9 dígitos';
                  return null;
                },
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              _buildTextFormField(
                _curpController,
                'CURP',
                'Ingresa tu CURP (18 caracteres)',
                (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (value.length != 18) {
                    return 'La CURP debe tener 18 caracteres';
                  }
                  if (!RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[0-9A-Z]{2}$')
                      .hasMatch(value)) {
                    return 'Formato de CURP inválido';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
              ),
              TextFormField(
                controller: _fechaNacimientoController,
                decoration: InputDecoration(
                  labelText: 'Fecha de Nacimiento',
                  hintText: 'DD/MM/AAAA',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  return null;
                },
              ),
              _buildTextFormField(
                _correoInstitucionalController,
                'Correo Institucional',
                'ejemplo@test.edu.mx',
                (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (!value.endsWith('@test.edu.mx')) {
                    return 'El correo debe terminar en @test.edu.mx';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextFormField(
                _telefonoController,
                'Teléfono',
                'Ingresa tu teléfono a 10 dígitos',
                (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Solo números';
                  }
                  if (value.length != 10)
                    return 'El teléfono debe tener 10 dígitos';
                  return null;
                },
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              _buildTextFormField(
                _entidadController,
                'Entidad Federativa',
                'Ej. Ciudad de México',
                (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  return null;
                },
              ),
              _buildTextFormField(
                _municipioController,
                'Municipio',
                'Ej. Cuauhtémoc',
                (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  return null;
                },
              ),
              _buildTextFormField(
                _coloniaController,
                'Colonia',
                'Ej. Centro',
                (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  return null;
                },
              ),
              _buildTextFormField(
                _calleController,
                'Calle y Número',
                'Ej. Av. Insurgentes Sur #123',
                (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarDatosAlumno,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Guardar Información Personal',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label,
    String hint,
    String? Function(String?)? validator, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
      ),
    );
  }
}
