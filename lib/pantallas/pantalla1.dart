import 'package:flutter/material.dart';
import '../recursos/colores.dart';
import '../recursos/constantes.dart';

class PantallaRegistrar extends StatelessWidget {
  const PantallaRegistrar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Gasto', style: AppEstilos.textoBoton),
        backgroundColor: AppColores.verdePrimario,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColores.verdeClaro,
      body: Center(
        child: Container(
          margin: AppConstantes.miwp,
          padding: AppConstantes.miwpL,
          decoration: BoxDecoration(
            color: AppColores.verdeSuave,
            borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
            boxShadow: [
              BoxShadow(
                color: AppColores.verdePrimario.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColores.verdePrimario,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_circle_outline,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              AppConstantes.espacioMedioWidget,
              Text(
                'Bienvenido al Registro',
                style: AppEstilos.tituloMedio.copyWith(
                  color: AppColores.verdePrimario,
                ),
              ),
              AppConstantes.espacioChicoWidget,
              Text(
                'Registra tus gastos fácilmente 💰',
                style: AppEstilos.textoNormal,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
