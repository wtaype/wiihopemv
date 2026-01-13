import 'package:flutter/material.dart';
import 'wiauth.dart';
import '../../wii.dart';

class PantallaTerminos extends StatelessWidget {
  const PantallaTerminos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColores.verdeClaro,
      appBar: AppBar(
        title: Text('Términos y Condiciones', style: AuthEstilos.textoBoton),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AuthConstantes.espacioMedio,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthConstantes.espacioMedioWidget,

            // 🎨 Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AuthConstantes.espacioGrande),
              decoration: BoxDecoration(
                color: AuthColores.verdeSuave,
                borderRadius: BorderRadius.circular(AuthConstantes.radioMedio),
                boxShadow: [
                  BoxShadow(
                    color: AuthColores.verdePrimario.withOpacity(0.2),
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
                      color: AuthColores.verdePrimario,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.gavel, size: 40, color: Colors.white),
                  ),
                  AuthConstantes.espacioChicoWidget,
                  Text('Términos y Condiciones', style: AuthEstilos.subtitulo),
                  Text(
                    '${wii.app}  ${wii.version}',
                    style: AuthEstilos.textoNormal,
                  ),
                ],
              ),
            ),

            AuthConstantes.espacioGrandeWidget,

            // 📝 Contenido de términos
            _seccionTerminos(
              '1. Aceptación de Términos',
              'Al usar WiiHope, aceptas estos términos y condiciones en su totalidad. Si no estás de acuerdo, no uses la aplicación.',
            ),

            _seccionTerminos(
              '2. Uso de la Aplicación',
              'WiiHope es una aplicación para registrar y gestionar gastos personales y grupales. Úsala de manera responsable y legal.',
            ),

            _seccionTerminos(
              '3. Datos Personales',
              'Protegemos tu información personal. Solo recopilamos datos necesarios para el funcionamiento de la app: email, nombre, usuario y gastos registrados.',
            ),

            _seccionTerminos(
              '4. Responsabilidades',
              'Eres responsable de mantener segura tu cuenta y contraseña. WiiHope no se hace responsable por el uso no autorizado de tu cuenta.',
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

            AuthConstantes.espacioGrandeWidget,

            // 📅 Fecha
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AuthConstantes.espacioMedio),
              decoration: BoxDecoration(
                color: AuthColores.verdeSuave.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AuthConstantes.radioChico),
              ),
              child: Column(
                children: [
                  Icon(Icons.calendar_today, color: AuthColores.verdePrimario),
                  AuthConstantes.espacioChicoWidget,
                  Text(
                    'Última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: AuthEstilos.textoChico,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Al usar la app, aceptas estos términos automáticamente',
                    style: AuthEstilos.textoChico,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            AuthConstantes.espacioGrandeWidget,

            // 🔗 Botón volver
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.check_circle),
                label: Text('Entendido'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AuthColores.verdePrimario,
                  padding: EdgeInsets.symmetric(
                    vertical: AuthConstantes.espacioMedio,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AuthConstantes.radioMedio,
                    ),
                  ),
                ),
              ),
            ),

            AuthConstantes.espacioGrandeWidget,
          ],
        ),
      ),
    );
  }

  // 📝 Widget para cada sección - REUTILIZABLE
  Widget _seccionTerminos(String titulo, String contenido) => Container(
    margin: EdgeInsets.only(bottom: AuthConstantes.espacioMedio),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: AuthEstilos.subtitulo.copyWith(
            color: AuthColores.verdePrimario,
            fontWeight: FontWeight.w600,
          ),
        ),
        AuthConstantes.espacioChicoWidget,
        Text(
          contenido,
          style: AuthEstilos.textoNormal,
          textAlign: TextAlign.justify,
        ),
        AuthConstantes.espacioMedioWidget,
      ],
    ),
  );
}
