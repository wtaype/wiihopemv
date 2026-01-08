import 'package:flutter/material.dart';
import '../recursos/colores.dart';
import '../wiauth/login.dart';
import '../wiauth/auth_fb.dart';
import '../pantallas/principal.dart';

class PantallaCargando extends StatefulWidget {
  const PantallaCargando({super.key});

  @override
  State<PantallaCargando> createState() => _PantallaCargandoState();
}

class _PantallaCargandoState extends State<PantallaCargando> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => AuthServicio.estaLogueado
                ? const PantallaPrincipal()
                : const PantallaLogin(),
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColores.verdeClaro,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColores.verdePrimario,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text('WiiHope', style: AppEstilos.tituloGrande),
        ],
      ),
    ),
  );
}
