import 'package:flutter/material.dart';
import 'package:login_app/modelos/modelo_grupo.dart'; // Importa tu modelo Grupo
import 'package:login_app/servicio/firestore_service.dart'; // Importa tu FirestoreService
import 'package:login_app/reinscripcion/asignaturas.dart'; // Para navegar a la selección de asignaturas

class Selecciongrupo extends StatefulWidget {
  final String semesterId;
  final String semesterName;

  const Selecciongrupo({
    super.key,
    required this.semesterId, // Requiere el ID
    required this.semesterName,
  });

  @override
  State<Selecciongrupo> createState() => _SelecciongrupoState();
}

class _SelecciongrupoState extends State<Selecciongrupo> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.semesterName}'), //Selecciona el grupo
        backgroundColor: Colors.white10,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selecciona el grupo',
              //'Selecciona el Grupo para ${widget.semesterName}',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              // Usamos StreamBuilder para escuchar cambios en tiempo real
              child: StreamBuilder<List<Grupo>>(
                stream:
                    _firestoreService.getGruposPorSemestre(widget.semesterId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    print("Error al cargar grupos: ${snapshot.error}");
                    return Center(
                        child:
                            Text('Error al cargar grupos: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text(
                            'No hay grupos disponibles para este semestre.'));
                  }

                  final grupos = snapshot.data!;
                  return ListView.builder(
                    itemCount: grupos.length,
                    itemBuilder: (context, index) {
                      final group = grupos[index];
                      // Puedes añadir lógica de color para los grupos si lo deseas
                      Color buttonColor =
                          Theme.of(context).colorScheme.secondary;
                      if (index % 2 == 0) {
                        buttonColor = const Color.fromARGB(255, 244, 247, 112);
                      } else {
                        buttonColor = const Color.fromARGB(255, 252, 193, 145);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            minimumSize: const Size.fromHeight(50),
                          ),
                          onPressed: () {
                            // Navega a la pantalla de selección de asignaturas
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Seleccion_Asignaturas(
                                  groupId: group.idGrupo,
                                  groupName: group.nombreGrupo,
                                  semesterId: group
                                      .idSemestre, // Pasa el ID del semestre
                                  semesterName: widget
                                      .semesterName, // Pasa el nombre del semestre
                                ),
                              ),
                            );
                          },
                          child: Text(
                            ' ${group.nombreGrupo}', //'grupo ${}', podria ser la opcion
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
