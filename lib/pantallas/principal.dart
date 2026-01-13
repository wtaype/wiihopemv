import 'package:flutter/material.dart';
import '../wicss.dart';
import 'pantalla1/oracion.dart';
import 'pantalla2/citas.dart';
import 'pantalla3/audio.dart';
import 'pantalla4/acerca.dart';
import 'pantalla5/configuracion.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final List<Widget> _pantallas = const [
    PantallaOracion(),
    PantallaCitas(),
    PantallaAudio(),
    PantallaAcerca(),
    PantallaConfiguracion(),
  ];

  late final PageController _pageController;
  int _indice = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _indice);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppCSS.verdeClaro,
    body: PageView(
      controller: _pageController,
      onPageChanged: (i) => setState(() => _indice = i),
      children: _pantallas,
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _indice,
      onTap: (i) {
        setState(() => _indice = i);
        _pageController.animateToPage(
          i,
          duration: AppCSS.animacionRapida,
          curve: Curves.easeInOut,
        );
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppCSS.verdePrimario,
      unselectedItemColor: AppCSS.gris,
      selectedLabelStyle: AppEstilos.icoSM.copyWith(
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: AppEstilos.txtSM,
      elevation: 10,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.volunteer_activism_outlined),
          activeIcon: Icon(Icons.volunteer_activism),
          label: 'Oración',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.format_quote_outlined),
          activeIcon: Icon(Icons.format_quote),
          label: 'Citas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music_outlined),
          activeIcon: Icon(Icons.library_music),
          label: 'Audio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info_outline),
          activeIcon: Icon(Icons.info),
          label: 'Acerca',
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
