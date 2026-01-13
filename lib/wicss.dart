import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 🎨 ===== COLORES =====
class AppCSS {
  static const String descripcion =
      'La mejor app para registrar y dividir gastos con amigos';
  static const String creadoBy = 'Con mucho amor ❤️';

  // Assets
  static const String _logoPath = 'assets/images/logo.png';
  static const String logoSmile = 'assets/images/smile.png';

  static Widget get miLogo => Image.asset(
    _logoPath,
    width: 80,
    height: 80,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) =>
        const Icon(Icons.account_circle, size: 80, color: AppCSS.verdePrimario),
  );

  static Widget get miLogoCircular => Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: AppCSS.verdePrimario.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: ClipOval(child: miLogo),
  );

  // Verdes principales
  static const Color verdePrimario = Color(0xFF4CAF50);
  static const Color verdeSecundario = Color(0xFF81C784);
  static const Color verdeClaro = Color(0xFFB9F6CA);
  static const Color verdeSuave = Color(0xFFE8F5E8);
  static const Color verdeOscuro = Color(0xFF388E3C);

  // Textos
  static const Color textoOscuro = Color(0xFF2E2E2E);
  static const Color textoVerde = Color(0xFF388E3C);
  static const Color blanco = Colors.white;
  static const Color enlace = Color(0xFF4CAF50);

  // Estados
  static const Color error = Color(0xFFE53935);
  static const Color exito = Color(0xFF4CAF50);
  static const Color advertencia = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Grises
  static const Color gris = Color(0xFF9E9E9E);
  static const Color grisClaro = Color(0xFFF5F5F5);
  static const Color grisOscuro = Color(0xFF424242);

  // Extras
  static const Color transparente = Colors.transparent;
  static const Color sombra = Color(0x1A000000);

  // 📐 ===== ESPACIADOS =====
  static const double espacioChico = 8.0;
  static const double espacioMedio = 16.0;
  static const double espacioGrande = 24.0;
  static const double espacioGigante = 32.0;

  // 📐 ===== RADIOS =====
  static const double radioChico = 8.0;
  static const double radioMedio = 12.0;
  static const double radioGrande = 16.0;

  // ⏱️ ===== DURACIONES =====
  static const Duration animacionRapida = Duration(milliseconds: 300);
  static const Duration animacionLenta = Duration(milliseconds: 600);
  static const Duration tiempoCarga = Duration(seconds: 3);

  // 📱 ===== PADDINGS =====
  static const EdgeInsets miwp = EdgeInsets.symmetric(
    vertical: 9.0,
    horizontal: 10.0,
  );
  static const EdgeInsets miwpL = EdgeInsets.symmetric(
    vertical: 15.0,
    horizontal: 20.0,
  );
  static const EdgeInsets miwpM = EdgeInsets.only(
    top: 10.0,
    bottom: 15.0,
    right: 10.0,
    left: 10.0,
  );
  static const EdgeInsets miwpS = EdgeInsets.all(espacioChico);
  static const EdgeInsets miwpXL = EdgeInsets.all(espacioGigante);

  // 🎨 ===== ESPACIADORES =====
  static Widget get espacioChicoWidget => const SizedBox(height: espacioChico);
  static Widget get espacioMedioWidget => const SizedBox(height: espacioMedio);
  static Widget get espacioGrandeWidget =>
      const SizedBox(height: espacioGrande);
}

// 🎭 ===== ESTILOS DE TEXTO =====
class AppEstilos {
  static ThemeData get temaApp => ThemeData(
    scaffoldBackgroundColor: AppCSS.verdeClaro,
    primarySwatch: Colors.green,
    fontFamily: GoogleFonts.poppins().fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: AppCSS.verdePrimario,
      foregroundColor: AppCSS.blanco,
      elevation: 4.0,
      toolbarHeight: 45.0,
      titleTextStyle: textoBoton,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppCSS.blanco, size: 22.0),
      shadowColor: AppCSS.verdePrimario.withOpacity(0.3),
    ),
    textTheme: TextTheme(
      headlineLarge: tituloGrande,
      headlineMedium: tituloMedio,
      titleLarge: subtitulo,
      bodyLarge: textoNormal,
      bodyMedium: textoChico,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppCSS.verdePrimario,
        foregroundColor: AppCSS.blanco,
        textStyle: textoBoton,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static TextStyle get tituloGrande => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppCSS.textoVerde,
  );

  static TextStyle get tituloMedio => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppCSS.textoVerde,
  );

  static TextStyle get subtitulo => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppCSS.textoOscuro,
  );

  static TextStyle get textoNormal => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppCSS.textoOscuro,
  );

  static TextStyle get textoChico => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppCSS.textoOscuro,
  );

  static TextStyle get icoSM => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppCSS.textoOscuro,
  );

  static TextStyle get txtSM => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppCSS.textoOscuro,
  );

  static TextStyle get textoBoton => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppCSS.blanco,
  );
}

// 🎨 ===== COLORES DE VALIDACIÓN =====
class VdError {
  static const Color borde = Color(0xFFE53935);
  static const Color texto = Color(0xFFD32F2F);
  static const Color fondo = Color(0xFFFFEBEE);
  static const Color icono = Color(0xFFE53935);
}

class VdGreen {
  static const Color borde = Color(0xFF4CAF50);
  static const Color texto = Color(0xFF2E7D32);
  static const Color fondo = Color(0xFFE8F5E8);
  static const Color icono = Color(0xFF4CAF50);
}
