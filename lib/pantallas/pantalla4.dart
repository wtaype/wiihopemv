import 'package:flutter/material.dart';
import '../recursos/colores.dart';
import '../recursos/constantes.dart';

class PantallaMensajes extends StatelessWidget {
  const PantallaMensajes({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Mensajes', style: AppEstilos.textoBoton),
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
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColores.verdePrimario,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble,
                size: 40,
                color: Colors.white,
              ),
            ),
            AppConstantes.espacioMedioWidget,
            Text(
              'Bienvenido a Mensajes',
              style: AppEstilos.tituloMedio.copyWith(
                color: AppColores.verdePrimario,
              ),
            ),
            AppConstantes.espacioChicoWidget,
            Text(
              'Chatea con tus amigos 💬',
              style: AppEstilos.textoNormal,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
