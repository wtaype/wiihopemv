import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../wicss.dart';

class PantallaAcerca extends StatelessWidget {
  const PantallaAcerca({super.key});

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Acerca de nosotros',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppCSS.verdePrimario,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppCSS.verdeClaro,
      body: SingleChildScrollView(
        padding: AppCSS.miwp,
        child: Column(
          children: [
            // Logo/Icono
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppCSS.verdePrimario,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppCSS.verdePrimario.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.church, size: 50, color: Colors.white),
            ),
            AppCSS.espacioMedioWidget,

            // Título
            Text(
              'Wiihope',
              style: AppEstilos.tituloGrande.copyWith(
                color: AppCSS.verdePrimario,
              ),
            ),
            AppCSS.espacioChicoWidget,

            // Contenido principal
            Container(
              padding: AppCSS.miwpL,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppCSS.radioMedio),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildParrafo(
                    'Wiihope es una aplicación diseñada para compartir y aprender más sobre la palabra de Dios. Su propósito es fortalecer la fe y ser una herramienta de protección, prosperidad y bendición.',
                  ),
                  _buildParrafo(
                    'En esta app encontrarás el Padre Nuestro, o como mi madre solía llamarlo, "el teléfono de Dios". Ella me decía que esta oración es la clave para comunicarnos con Él, ya que fue la que Jesús nos enseñó para mostrar cómo orar correctamente.',
                  ),
                  _buildParrafo(
                    'Además, hemos reunido las mejores frases de protección, salvación y seguridad en Dios para inspirarte en tu día a día. También podrás disfrutar de audios dramatizados del Nuevo Testamento en quechua, ideales para entender y transmitir el mensaje de una manera más cercana y enriquecedora.',
                  ),

                  // Enlace a Faith Comes By Hearing
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RichText(
                      text: TextSpan(
                        style: AppEstilos.textoNormal.copyWith(height: 1.5),
                        children: [
                          const TextSpan(text: 'Agradecemos a '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => _abrirUrl(
                                'https://www.faithcomesbyhearing.com/audio-bible-resources/mp3-downloads',
                              ),
                              child: Text(
                                'Faith Comes By Hearing',
                                style: AppEstilos.textoNormal.copyWith(
                                  color: AppCSS.verdePrimario,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(
                            text:
                                ', la creadora de este contenido maravilloso, por permitirnos incluirlo en Wiihope. Esta app fue desarrollada por mí, Wilder Taype, con el objetivo de digitalizar estos recursos y hacerlos accesibles para más personas.',
                          ),
                        ],
                      ),
                    ),
                  ),

                  _buildParrafo(
                    'Si llegaste hasta aquí, ¡Dios te bendiga! Y si no, también, porque su amor y cuidado están contigo siempre. ¡Recuerda avanzar con fe y confianza!',
                  ),

                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Con amor.',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  // Firma
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppCSS.verdeSuave,
                      borderRadius: BorderRadius.circular(AppCSS.radioChico),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wilder Taype',
                          style: AppEstilos.textoNormal.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Creador de Wiihope',
                          style: AppEstilos.textoNormal.copyWith(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppCSS.espacioMedioWidget,

            // Versión de la app
            Text(
              'Versión 1.0.0',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            AppCSS.espacioChicoWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildParrafo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        texto,
        style: AppEstilos.textoNormal.copyWith(height: 1.5),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
