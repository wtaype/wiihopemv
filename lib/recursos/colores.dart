import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 🎨 Nuestra paleta de colores completa
class AppColores {
  // 🌿 Verdes gorditos y bonitos
  static const Color verdePrimario = Color(0xFF4CAF50);
  static const Color verdeSecundario = Color(0xFF81C784);
  static const Color verdeClaro = Color(0xFFB9F6CA);
  static const Color verdeSuave = Color(0xFFE8F5E8);

  // 🖤 Textos
  static const Color textoOscuro = Color(0xFF2E2E2E);
  static const Color textoVerde = Color(0xFF388E3C);
  static const Color blanco = Colors.white;

  // 🔗 NUEVO: Color para enlaces
  static const Color enlace = Color(0xFF4CAF50); // 🔥 Verde para enlaces

  // 🚨 Estados y mensajes
  static const Color error = Color(0xFFE53935);
  static const Color exito = Color(0xFF4CAF50);
  static const Color advertencia = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // 🎨 UI adicionales
  static const Color gris = Color(0xFF9E9E9E);
  static const Color grisClaro = Color(0xFFF5F5F5);
  static const Color grisOscuro = Color(0xFF424242);

  // 🌟 Extras para casos especiales
  static const Color transparente = Colors.transparent;
  static const Color sombra = Color(0x1A000000);
}

// 🎭 Nuestro "CSS root" - ¡Poppins centralizado!
class AppEstilos {
  static ThemeData get temaApp => ThemeData(
    scaffoldBackgroundColor: AppColores.verdeClaro,
    primarySwatch: Colors.green,

    // 🎭 ¡Fuente por defecto para TODA la app!
    fontFamily: GoogleFonts.poppins().fontFamily, // Como tu * en CSS
    // 📱 AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColores.verdePrimario,
      foregroundColor: AppColores.blanco,
      elevation: 4.0,
      toolbarHeight: 45.0,
      titleTextStyle: textoBoton,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColores.blanco, size: 22.0),
      shadowColor: AppColores.verdePrimario.withOpacity(0.3),
    ),

    // 🎯 Text theme
    textTheme: TextTheme(
      headlineLarge: tituloGrande,
      headlineMedium: tituloMedio,
      titleLarge: subtitulo,
      bodyLarge: textoNormal,
      bodyMedium: textoChico,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColores.verdePrimario,
        foregroundColor: AppColores.blanco,
        textStyle: textoBoton,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  // 📝 Títulos gorditos
  static TextStyle get tituloGrande => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColores.textoVerde,
  );

  static TextStyle get tituloMedio => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColores.textoVerde,
  );

  static TextStyle get subtitulo => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColores.textoOscuro,
  );

  // 📱 Textos normales
  static TextStyle get textoNormal => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColores.textoOscuro,
  );

  static TextStyle get textoChico => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColores.textoOscuro,
  );

  static TextStyle get icoSM => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColores.textoOscuro,
  );

  static TextStyle get txtSM => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColores.textoOscuro,
  );

  // 🎯 Botones
  static TextStyle get textoBoton => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColores.blanco,
  );
}

// 🎯 Clases de validación visual
class VdError {
  static const Color borde = Color(0xFFE53935);
  static const Color texto = Color(0xFFD32F2F);
  static const Color fondo = Color(0xFFFFEBEE);
  static const Color icono = Color(0xFFE53935);

  // 🔥 InputDecoration lista para usar
  static InputDecoration decoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, color: icono),
    suffixIcon: suffixIcon,
    labelStyle: TextStyle(color: texto),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borde, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borde, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borde, width: 2),
    ),
    filled: true,
    fillColor: fondo,
  );
}

class VdGreen {
  static const Color borde = Color(0xFF4CAF50);
  static const Color texto = Color(0xFF2E7D32);
  static const Color fondo = Color(0xFFE8F5E8);
  static const Color icono = Color(0xFF4CAF50);

  // 🔥 InputDecoration lista para usar
  static InputDecoration decoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, color: icono),
    suffixIcon: suffixIcon,
    labelStyle: TextStyle(color: texto),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borde, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borde, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borde, width: 2),
    ),
    filled: true,
    fillColor: fondo,
  );
}
