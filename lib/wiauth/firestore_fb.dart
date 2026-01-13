import 'package:cloud_firestore/cloud_firestore.dart';
import 'wiauth.dart';
import 'usuario.dart';

class DatabaseServicio {
  static final _db = FirebaseFirestore.instance;
  static CollectionReference get _collection =>
      _db.collection(AuthFirebase.coleccionUsuarios);

  // 🔍 Verificar usuario existe - COMPACTO
  static Future<bool> usuarioExiste(String usuario) async {
    try {
      final doc = await _collection.doc(AuthFormatos.usuario(usuario)).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // 📧 Verificar email existe - COMPACTO
  static Future<bool> emailExiste(String email) async {
    try {
      final query = await _collection
          .where('email', isEqualTo: AuthFormatos.email(email))
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // 💾 Guardar usuario - COMPACTO con retry automático
  static Future<void> guardarUsuario(Usuario usuario) async {
    try {
      await _collection.doc(usuario.usuarioLimpio).set(usuario.toFirestore());

      // 🐢 Delay para tortuga Firestore
      await Future.delayed(AuthFirebase.delayVerificacion);

      // 🔍 Verificación + retry automático
      final verificacion = await _collection.doc(usuario.usuarioLimpio).get();
      if (!verificacion.exists) {
        await Future.delayed(AuthConstantes.animacionRapida);
        await _collection.doc(usuario.usuarioLimpio).set(usuario.toFirestore());
      }
    } catch (e) {
      // 🔄 Retry en caso de error
      await Future.delayed(AuthConstantes.animacionRapida);
      await _collection.doc(usuario.usuarioLimpio).set(usuario.toFirestore());
    }
  }

  // 🔍 Obtener usuario - COMPACTO
  static Future<Usuario?> obtenerUsuario(String usuario) async {
    try {
      final doc = await _collection.doc(AuthFormatos.usuario(usuario)).get();
      return doc.exists ? Usuario.fromFirestore(doc) : null;
    } catch (e) {
      return null;
    }
  }

  // 📧 Obtener email por usuario - UNA LÍNEA
  static Future<String?> obtenerEmailPorUsuario(String usuario) async =>
      (await obtenerUsuario(usuario))?.email;

  // ⏰ Actualizar actividad - COMPACTO
  static Future<void> actualizarUltimaActividad(String usuario) async {
    try {
      await _collection.doc(AuthFormatos.usuario(usuario)).update({
        'ultimaActividad': Timestamp.now(),
      });
    } catch (_) {} // Silent fail
  }

  // 🔥 NUEVO: Obtener usuario por email para configuración con cache
  static Future<Usuario?> obtenerUsuarioPorEmail(String email) async {
    try {
      print('🌐 Leyendo usuario desde Firebase por email: $email');
      final query = await _collection
          .where('email', isEqualTo: AuthFormatos.email(email))
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return Usuario.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo usuario por email: $e');
      return null;
    }
  }

  // 🔥 NUEVO: Actualizar foto de perfil en Firebase
  static Future<void> actualizarFotoPerfil(
    String usuario,
    String? fotoUrl,
  ) async {
    try {
      await _collection.doc(AuthFormatos.usuario(usuario)).update({
        'foto': fotoUrl,
        'ultimaActividad': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error actualizando foto: $e');
    }
  }
}
