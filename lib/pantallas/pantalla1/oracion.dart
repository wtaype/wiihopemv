import 'dart:async';
import 'package:flutter/material.dart';
import '../../wicss.dart';
import '../../widev.dart';

class PantallaOracion extends StatefulWidget {
  const PantallaOracion({super.key});

  @override
  State<PantallaOracion> createState() => _PantallaOracionState();
}

class _PantallaOracionState extends State<PantallaOracion> {
  bool _pulsoGrande = true;

  @override
  void initState() {
    super.initState();
    Timer.run(_togglePulso);
  }

  void _togglePulso() {
    if (!mounted) return;
    setState(() => _pulsoGrande = !_pulsoGrande);
    Future.delayed(const Duration(milliseconds: 900), _togglePulso);
  }

  void _mostrarAmen() => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Amén! Dios te ama 🙏', textAlign: TextAlign.center),
      backgroundColor: AppCSS.verdePrimario,
      behavior: SnackBarBehavior.fixed,
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppCSS.verdeClaro,
    appBar: AppBar(
      title: Text('Oración', style: AppEstilos.textoBoton),
      centerTitle: true,
      backgroundColor: AppCSS.verdePrimario,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      elevation: 0,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: AppCSS.miwpL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppWidgets.imagenRedondeada('assets/images/jesus.webp'),
            AppCSS.espacioChicoWidget,
            _buildTitulo(),
            AppCSS.espacioChicoWidget,
            AppWidgets.contenedorOracion(_textoPadreNuestro),
            AppCSS.espacioChicoWidget,
            _buildBotonesAccion(),
          ],
        ),
      ),
    ),
  );

  Widget _buildTitulo() => Column(
    children: [
      Text(
        'Padre Nuestro',
        style: AppEstilos.tituloMedio.copyWith(
          color: AppCSS.verdePrimario,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: .3),
      Text(
        '(Teléfono de Dios)',
        style: AppEstilos.textoChico.copyWith(
          color: AppCSS.verdeOscuro.withOpacity(0.7),
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _buildBotonesAccion() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      AppWidgets.corazonPulso(_pulsoGrande),
      const SizedBox(width: 14),
      ElevatedButton.icon(
        onPressed: _mostrarAmen,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppCSS.verdePrimario,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppCSS.radioMedio),
          ),
        ),
        icon: const Icon(Icons.volunteer_activism),
        label: const Text('Amén'),
      ),
    ],
  );

  static const _textoPadreNuestro = '''
Padre nuestro, que estás en el cielo,
santificado sea tu Nombre;
venga a nosotros tu reino;
hágase tu voluntad
en la tierra como en el cielo.

Danos hoy nuestro pan de cada día;
perdona nuestras ofensas,
como también nosotros perdonamos
a los que nos ofenden;
no nos dejes caer en la tentación,
y líbranos del mal.
''';
}