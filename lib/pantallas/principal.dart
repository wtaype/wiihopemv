import 'package:flutter/material.dart';
import '../recursos/colores.dart';
import '../recursos/constantes.dart';
import 'pantalla1.dart';
import 'pantalla2.dart';
import 'pantalla3.dart';
import 'pantalla4.dart';
import 'pantalla5.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceActual = 0;
  late PageController _pageController;

  final List<Widget> _pantallas = const [
    PantallaRegistrar(),
    PantallaGastos(),
    PantallaMensajes(),
    PantallaArreglar(),
    PantallaConfiguracion(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _indiceActual);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColores.verdeClaro,
    body: PageView(
      controller: _pageController,
      onPageChanged: (index) => setState(() => _indiceActual = index),
      children: _pantallas,
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _indiceActual,
      onTap: (index) {
        setState(() => _indiceActual = index);
        _pageController.animateToPage(
          index,
          duration: AppConstantes.animacionRapida,
          curve: Curves.easeInOut,
        );
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColores.verdePrimario,
      unselectedItemColor: AppColores.gris,
      selectedLabelStyle: AppEstilos.icoSM.copyWith(
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: AppEstilos.txtSM,
      elevation: 10,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: 'Registrar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Gastos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'Mensajes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.verified_outlined),
          activeIcon: Icon(Icons.verified),
          label: 'Arreglar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Configuración',
        ),
      ],
    ),
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
