import 'package:flutter/material.dart';
import '../recursos/colores.dart';
import '../recursos/constantes.dart';

class PantallaTerminos extends StatelessWidget {
  const PantallaTerminos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.verdeClaro,
      appBar: AppBar(
        title: Text('Términos y Condiciones', style: AppEstilos.textoBoton),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppConstantes.miwp,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎨 Header
            Container(
              width: double.infinity,
              padding: AppConstantes.miwpL,
              decoration: BoxDecoration(
                color: AppColores.verdeSuave,
                borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
                boxShadow: [
                  BoxShadow(
                    color: AppColores.verdePrimario.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColores.verdePrimario,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.gavel, size: 40, color: Colors.white),
                  ),
                  AppConstantes.espacioChicoWidget,
                  Text('Términos y Condiciones', style: AppEstilos.tituloMedio),
                  Text(
                    '${AppConstantes.nombreApp} v${AppConstantes.version}',
                    style: AppEstilos.textoNormal,
                  ),
                ],
              ),
            ),

            AppConstantes.espacioGrandeWidget,

            // 📝 Contenido de términos
            _seccionTerminos(
              '1. Aceptación de Términos',
              'Al usar ${AppConstantes.nombreApp}, aceptas estos términos y condiciones en su totalidad. Si no estás de acuerdo, no uses la aplicación.',
            ),

            _seccionTerminos(
              '2. Uso de la Aplicación',
              '${AppConstantes.nombreApp} es una aplicación para registrar y gestionar gastos personales y grupales. Úsala de manera responsable y legal.',
            ),

            _seccionTerminos(
              '3. Datos Personales',
              'Protegemos tu información personal. Solo recopilamos datos necesarios para el funcionamiento de la app: email, nombre, usuario y gastos registrados.',
            ),

            _seccionTerminos(
              '4. Responsabilidades',
              'Eres responsable de mantener segura tu cuenta y contraseña. ${AppConstantes.nombreApp} no se hace responsable por el uso no autorizado de tu cuenta.',
            ),

            _seccionTerminos(
              '5. Contenido',
              'El contenido que ingreses (gastos, nombres, grupos) es de tu propiedad. Nos das permiso para almacenarlo y procesarlo para brindarte el servicio.',
            ),

            _seccionTerminos(
              '6. Modificaciones',
              'Podemos actualizar estos términos ocasionalmente. Te notificaremos de cambios importantes a través de la aplicación.',
            ),

            _seccionTerminos(
              '7. Contacto',
              'Para preguntas sobre estos términos, contáctanos a través de la sección de ayuda en la aplicación.',
            ),

            AppConstantes.espacioGrandeWidget,

            // 📅 Fecha
            Container(
              width: double.infinity,
              padding: AppConstantes.miwp,
              decoration: BoxDecoration(
                color: AppColores.verdeSuave.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppConstantes.radioChico),
              ),
              child: Column(
                children: [
                  Icon(Icons.calendar_today, color: AppColores.verdePrimario),
                  AppConstantes.espacioChicoWidget,
                  Text(
                    'Última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: AppEstilos.textoChico,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Al usar la app, aceptas estos términos automáticamente',
                    style: AppEstilos.textoChico,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            AppConstantes.espacioGrandeWidget,

            // 🔗 Botón volver
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.check_circle),
                label: Text('Entendido'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColores.verdePrimario,
                  padding: EdgeInsets.symmetric(
                    vertical: AppConstantes.espacioMedio,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstantes.radioMedio,
                    ),
                  ),
                ),
              ),
            ),

            AppConstantes.espacioGrandeWidget,
          ],
        ),
      ),
    );
  }

  // 📝 Widget para cada sección - REUTILIZABLE
  Widget _seccionTerminos(String titulo, String contenido) => Container(
    margin: EdgeInsets.only(bottom: AppConstantes.espacioMedio),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: AppEstilos.subtitulo.copyWith(
            color: AppColores.verdePrimario,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppConstantes.espacioChicoWidget,
        Text(
          contenido,
          style: AppEstilos.textoNormal,
          textAlign: TextAlign.justify,
        ),
        AppConstantes.espacioMedioWidget,
      ],
    ),
  );
}
