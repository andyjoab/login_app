/*import 'dart:io';
import 'package: pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package: open_filex/open_filex.dart';

import 'package: login_app/modelos/firestore_service.dart';
import 'package: login_app/modelos/modelo_alumno.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts_pdf/google_fonts_pdf.dart';
import 'package:login_app/modelos/modelo_asignatura.dart';
import 'package:login_app/modelos/modelo_ofertaacademica.dart';
import 'package:login_app/modelos/modelo_grupo.dart';

class GeneradorPdf {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> generarPdf(String alumnoUid) async {
    try {
      // Obtener los datos del alumno desde Firestore
      final alumnoData = await _firestoreService.getAlumnoData(alumnoUid);
      if (alumnoData == null) {
        throw Exception('No se encontraron datos para el alumno con UID: $alumnoUid');
      }

      // Crear un documento PDF
      final pdf = pw.Document();
      
      final font = await PdfGoogleFonts.nunitoRegular();
      final boldFont = await PdfGoogleFonts.nunitoBold();


      // Agregar contenido al PDF
      pdf.addPage(
pw.MultiPage(
  pageFormat: PdfPageFormat.a4.copyWith(
    marginBottom: 1.5 * PdfPageFormat.cm,
    marginTop: 1.5 * PdfPageFormat.cm,
    marginLeft: 2.0 * PdfPageFormat.cm,
    marginRight: 2.0 * PdfPageFormat.cm,
  ),
  build: (pw.Context context) =>[
    _buildHeader(alumnoData,boldFont),
    pw.SizedBox(height: 20),

    pw.Center(
      child: pw.Text(
        'Carga academica del alumno',
        style: pw.TextStyle(font: boldFont, fontSize: 24),
      ),
    ),
    pw.SizedBox(height: 10),

    _buildMateriasTable()
    )
  ]
  }
)
        
            );
          },
        ),
      );

      // Guardar el PDF en un archivo
      final outputFile = File('alumno_$alumnoUid.pdf');
      await outputFile.writeAsBytes(await pdf.save());

      print('PDF generado exitosamente: ${outputFile.path}');
    } catch (e) {
      print('Error al generar el PDF: $e');
    }

  }
}
*/
