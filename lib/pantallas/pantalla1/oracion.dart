import 'dart:async';
import 'package:flutter/material.dart';
import '../../wicss.dart';

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

  void _onAmen() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Amén 🙏')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              ClipRRect(
                borderRadius: BorderRadius.circular(AppCSS.radioMedio),
                child: Image.asset(
                  'assets/images/jesus.webp',
                  fit: BoxFit.cover,
                ),
              ),
              AppCSS.espacioGrandeWidget,
              Column(
                children: [
                  Text(
                    'Padre Nuestro',
                    style: AppEstilos.tituloMedio.copyWith(
                      color: AppCSS.verdePrimario,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '(Teléfono de Dios)',
                    style: AppEstilos.textoNormal.copyWith(
                      color: AppCSS.verdeOscuro.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              AppCSS.espacioMedioWidget,
              Container(
                padding: AppCSS.miwp,
                decoration: BoxDecoration(
                  color: AppCSS.verdeSuave,
                  borderRadius: BorderRadius.circular(AppCSS.radioMedio),
                ),
                child: Text(
                  '''
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
''',
                  style: AppEstilos.textoNormal.copyWith(
                    height: 1.5,
                    color: AppCSS.verdeOscuro,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              AppCSS.espacioGrandeWidget,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: _pulsoGrande ? 1.0 : 0.88,
                      end: _pulsoGrande ? 1.06 : 0.94,
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: Icon(
                      Icons.favorite,
                      color: AppCSS.verdePrimario,
                      size: 48,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _onAmen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppCSS.verdePrimario,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppCSS.radioMedio),
                      ),
                    ),
                    icon: const Icon(Icons.volunteer_activism),
                    label: const Text('Amén'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
