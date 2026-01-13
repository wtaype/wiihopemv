import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'wiauth.dart';
import 'firestore_fb.dart';
import 'usuario.dart';

class AuthServicio {
  static final _auth = FirebaseAuth.instance;

  // 🔐 Propiedades - UNA LÍNEA CADA UNA
  static User? get usuarioActual => _auth.currentUser;
  static bool get estaLogueado => usuarioActual != null;

  // 📧 Crear cuenta - COMPACTO
  static Future<User> crearCuenta(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: AuthFormatos.email(email),
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw Exception(AuthFirebase.mensajeError(e.code));
    }
  }

  // 🔑 Login - COMPACTO
  static Future<User> login(String emailOUsuario, String password) async {
    try {
      String email = AuthFormatos.email(emailOUsuario);

      // Si no es email, buscar por usuario - COMPACTO
      if (!EmailValidator.validate(emailOUsuario)) {
        final emailEncontrado = await DatabaseServicio.obtenerEmailPorUsuario(
          emailOUsuario,
        );
        if (emailEncontrado == null) throw Exception('Usuario no encontrado');
        email = emailEncontrado;
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar actividad si es usuario (no email)
      if (!EmailValidator.validate(emailOUsuario)) {
        DatabaseServicio.actualizarUltimaActividad(emailOUsuario);
      }

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw Exception(AuthFirebase.mensajeError(e.code));
    }
  }

  // 🚪 Cerrar sesión - UNA LÍNEA
  static Future<void> logout() async => await _auth.signOut();

  // 🔄 Restablecer contraseña - COMPACTO
  static Future<void> restablecerPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: AuthFormatos.email(email));
    } on FirebaseAuthException catch (e) {
      throw Exception(AuthFirebase.mensajeError(e.code));
    }
  }

  // 🔑 Login MEJORADO
  static Future<Usuario> loginMejorado(
    String emailOUsuario,
    String password,
  ) async {
    try {
      String email = AuthFormatos.emailOUsuario(emailOUsuario);
      Usuario? usuarioCompleto;

      // Si no es email, buscar por usuario
      if (!EmailValidator.validate(emailOUsuario)) {
        usuarioCompleto = await DatabaseServicio.obtenerUsuario(emailOUsuario);
        if (usuarioCompleto == null) {
          throw Exception('Usuario "$emailOUsuario" no encontrado');
        }
        email = usuarioCompleto.email;
      }

      // Hacer login con Firebase Auth
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Si no tenemos el usuario completo, obtenerlo por email
      if (usuarioCompleto == null) {
        usuarioCompleto = await DatabaseServicio.obtenerUsuarioPorEmail(email);
        if (usuarioCompleto == null) {
          throw Exception('Error obteniendo datos del usuario');
        }
      }

      // Actualizar última actividad
      await DatabaseServicio.actualizarUltimaActividad(usuarioCompleto.usuario);

      return usuarioCompleto;
    } on FirebaseAuthException catch (e) {
      throw Exception(AuthFirebase.mensajeError(e.code));
    }
  }
}
